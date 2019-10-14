# This operation is used for creating upcoming invoices for fixed periodic invoice
# Fixed periodic invoice can have multiple invoices generated within the start_date and end_date range
# Invoice freqency is allowed to be monthy only, hence considering 'month' as default period
class PaymentAgreements::CreateUpcomingInvoice < PaymentAgreements::Base

  # :first_reference_invoice is the reference invoice for creating first fixed_periodic invoice template
  # :new_upcoming_invoice => Upcoming invoice that  act as a template for the new actual invoice
  attr_accessor :payment_agreement, :previous_upcoming_invoice, :next_invoice_due_date, :valid_amount_invoice, :new_upcoming_invoice, :first_reference_invoice, :invoice_type, :vendor_id, :escalated_reference_invoice, :first_start_date, :effective_end_date

  def init
    payment_agreement_id = params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id payment_agreement_id
    self.first_reference_invoice = params[:first_reference_invoice] || false
    self.invoice_type = params[:first_reference_invoice_type]
    self.first_start_date = params[:first_start_date]
    # previous_upcoming_invoice is not required for first invoice
    # previous_upcoming_invoice is previous invoice template
    unless first_reference_invoice.present?
      self.previous_upcoming_invoice = params[:previous_upcoming_invoice]
      self.escalated_reference_invoice = params[:escalated_reference_invoice]
    end

    self.vendor_id = params[:vendor_id] || (first_reference_invoice.present? ? first_reference_invoice.vendor_id : previous_upcoming_invoice.vendor_id)
    # self.partial_invoice_ids = []
  end

  def validate
    if self.payment_agreement.blank?
      add_message :error, "Agreement not present while creating upcoming invoice"
      return
    end

    # If expiration date of agreement is in future, or no_expiration then only allow to create upcoming invoices
    unless self.payment_agreement.no_expiration || self.payment_agreement.expiration_date.to_date >= Date.today
      add_message :error, "Agreement is already expired!"
      return
    end

    if first_reference_invoice.present? && invoice_type.blank?
      add_message :error, "First upcoming invoice type cannot be black"
    end

    unless first_reference_invoice.present?
      if self.previous_upcoming_invoice.blank?
        add_message :error, "General and rental invoice both are not found"
        return
      end
      # Upcoming invoice creation is only allowed for agreement invoices with billing type fixed period
      unless self.previous_upcoming_invoice.billing_type.fixed_periodic?
        add_message :error, "Only fixed periodic agreement invoices can be auto-created"
        return
      end
    end

    # Invoice frequency should not cross expiration date of payment agreement
    # next_upcoming_invoice_required(previous_upcoming_invoice)
  end

  def process
    previous_upcoming_invoice_type = first_reference_invoice.present? ? first_reference_invoice.class.name : self.previous_upcoming_invoice.class.name
    case previous_upcoming_invoice_type
    when "GeneralInvoice"
      create_upcoming_general_invoice
    when "RentalInvoice"
      create_upcoming_rental_invoice
    end
  end

  def success
    params[:new_upcoming_invoice] = self.new_upcoming_invoice
    PaymentAgreements::CreateUpcomingInvoice::CreateUpcomingInvoicePresenter.new(user, params, messages)
  end

  class PaymentAgreements::CreateUpcomingInvoice::CreateUpcomingInvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :new_upcoming_invoice

    def init
      self.new_upcoming_invoice = params[:new_upcoming_invoice]
    end

  end

  def create_upcoming_general_invoice
    #First invoice ends at end of month of the invoice frequency period
    if first_reference_invoice
      create_first_upcoming_invoice('general_invoice', first_reference_invoice)
      # First upcoming invoice for fixed periodic contains first set of escalated invoices
      # if first_reference_invoice.fixed_periodic?
      #   reference_invoices = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id, start_date: execution_date)self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id, start_date: execution_date)
      # end
    else
      create_next_upcoming_invoice('general_invoice', previous_upcoming_invoice)
    end
  end

  def create_first_upcoming_invoice(invoice_type, reference_invoice)
    # First invoice can start from any date of month
    invoice_parameters = setup_invoice_params
    upcoming_invoice = invoice_type.camelize.constantize.new(invoice_parameters)
    # if upcoming_invoice.save
      map_line_items(reference_invoice, upcoming_invoice, {first_invoice: true})
    # end
    update_taxable_and_orig_amount_value(upcoming_invoice)
    upcoming_invoice.items.map(&:update_taxable_amount_value)
    InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, upcoming_invoice)
    # upcoming_invoice.end_date = effective_end_date
    if upcoming_invoice.save
      if upcoming_invoice.tds_slab_id.present?
        apply_tds_on_amount(upcoming_invoice)
      end
      update_balance_due_amount(upcoming_invoice, upcoming_invoice.net_amount.value)
    end
  end

  def map_line_items(reference_invoice, upcoming_invoice, options={})
    reference_invoice.invoice_items.each do |item|
      new_line_item = upcoming_invoice.invoice_items.new
      InvoiceLineItem::TEMPLATE_COLUMNS.each do |column_name|
        new_line_item.send("#{column_name}=", item.send(column_name.to_sym))
      end

      InvoiceLineItem::CLONE_RECORDS.each do |column_name|
        new_line_item.send("#{column_name}=", item.send(column_name.to_sym).dup)
      end
      new_line_item.parent_type = reference_invoice.class.name
      if options[:first_invoice]
        new_line_item.rate = get_first_invoice_rate(reference_invoice, item.rate)
      end
    end
    # upcoming_invoice.end_date = effective_end_date
    if upcoming_invoice.save!
      self.new_upcoming_invoice = upcoming_invoice
    end
  end

  def get_first_invoice_rate(reference_invoice, reference_invoice_item_rate)
    invoice_frequency_number = reference_invoice.invoice_frequency.number
    # This rate is for invoice frequency period
    rate = reference_invoice_item_rate
    one_month_rate = reference_invoice_item_rate/invoice_frequency_number
    # First invoice can have partial month
    frequency_based_end_date = (first_start_date + invoice_frequency_number.month - 1.month).end_of_month
    frequency_period_rate = calculate_frequency_month_rate(reference_invoice.start_date, reference_invoice.end_date, frequency_based_end_date, one_month_rate)
    # effective_frequency_period_rate = partial_month_rate + one_month_rate*(invoice_frequency_number-1)
    return frequency_period_rate
  end

  def calculate_frequency_month_rate(invoice_start_date, invoice_end_date, actual_end_date, one_month_rate)
    # Add one to adjust current day
    # effective_days_count = date.end_of_month.day - date.day + 1
    self.effective_end_date = invoice_end_date == actual_end_date ? invoice_end_date : actual_end_date
    if (invoice_start_date.month == invoice_end_date.month) && (invoice_start_date.year == invoice_end_date.year)
      effective_days_count = (invoice_end_date - invoice_start_date).to_i + 1
      days_in_month = invoice_start_date.end_of_month.day - invoice_start_date.beginning_of_month.day + 1
      effective_rate = (one_month_rate/days_in_month)*effective_days_count
    else
      effective_days_count = (effective_end_date - invoice_start_date).to_i + 1
      days_in_month = ((invoice_start_date.end_of_month.day - invoice_start_date.beginning_of_month.day).to_i + 1) + ((effective_end_date.end_of_month.day - effective_end_date.beginning_of_month.day).to_i + 1)
      # effective_months = invoice_start_date.month - effective_end_date.month + 1
      effective_months = first_reference_invoice.invoice_frequency.number
      effective_rate = (one_month_rate*effective_months/days_in_month)*effective_days_count
    end

    # effective_days_count = effective_end_date - invoice_start_date + 1
    # days_in_month = date.end_of_month.day - date.beginning_of_month.day + 1
    # effective_rate = (one_month_rate/days_in_month)*effective_days_count
    return effective_rate
  end


  def create_next_general_invoice
  end


  def create_upcoming_rental_invoice
    #First invoice ends at end of month of the invoice frequency period
    if first_reference_invoice
      create_first_upcoming_invoice('rental_invoice', first_reference_invoice)
    else
      create_next_upcoming_invoice('rental_invoice', previous_upcoming_invoice)
    end
  end

  # def next_upcoming_invoice_required(previous_upcoming_invoice)
  #   invoice_upcoming_date(previous_upcoming_invoice)
  #   if self.next_invoice_due_date.blank?
  #     add_message :error, "Period or upcoming date is not defined for #{previous_upcoming_invoice.class.name.titleize} "
  #     return
  #   end

  #   unless self.payment_agreement.no_expiration 
  #     if self.next_invoice_due_date.to_date > self.payment_agreement.expiration_date.to_date
  #       # Keep this partial invoice ids for future reference as this condition is not currently handled
  #       self.partial_invoice_ids.push(previous_upcoming_invoice.id)
  #       add_message :error, 'Next upcoming invoice due date cannot be after agreement expiration'
  #       return
  #     end
  #   end
  #   true
  # end

  # Return next upcoming date w.r.t the previous invoice and that will be previous invoice upcoming date + invoice frequency - 1 day
  # 1 month is complete when same date arrives in the next month
  # def invoice_upcoming_date(previous_upcoming_invoice)
  #   number = previous_upcoming_invoice.invoice_frequency.number
  #   period_id = previous_upcoming_invoice.invoice_frequency.period_id
  #   case period_id
  #   when Period.id_for(:month)
  #     self.next_invoice_due_date = previous_upcoming_invoice.payment_agreement_upcoming_date.to_date + number.to_i.month - 1.day
  #     return
  #   end
  #   return nil
  # end

  # Check which invoice hold next_invoice_due_date between start date and end date
  # Duplicate that invoice, this duplicated invoice will be new upcoming_invoice
  # This is valid only for fixed periodic invoices
  # def create_upcoming_general_invoice
  #   get_valid_amount_general_invoice
  #   if self.valid_amount_invoice.present?
  #     upcoming_general_invoice = self.valid_amount_invoice.amoeba_dup
  #     upcoming_general_invoice.template_invoice_id = self.valid_amount_invoice.id
  #     unless upcoming_general_invoice.save
  #       add_message :error, "Unable to create upcoming general invoice"
  #       return
  #     end
  #     self.new_upcoming_invoice = upcoming_general_invoice
  #   end
  # end

  # def create_upcoming_rental_invoice
  #   get_valid_amount_rental_invoice
  #   if self.valid_amount_invoice.present?
  #     upcoming_rental_invoice = self.valid_amount_invoice.amoeba_dup
  #     upcoming_rental_invoice.template_invoice_id = self.valid_amount_invoice.id
  #     unless upcoming_rental_invoice.save
  #       add_message :error, "Unable to create upcoming general invoice"
  #       return
  #     end
  #     self.new_upcoming_invoice = upcoming_rental_invoice
  #   end
  # end

  # def get_valid_amount_general_invoice
  #   self.payment_agreement.general_invoices.each do |general_invoice|
  #     if self.next_invoice_due_date >= general_invoice.start_date.to_date && self.next_invoice_due_date.to_date <= general_invoice.end_date.to_date
  #       self.valid_amount_invoice = general_invoice
  #       return
  #     end
  #   end
  #   # No agreement invoice is found with next_invoice_due_date in between start date and end date  
  #   if self.valid_amount_invoice.blank?
  #     add_message :error, "Valid amount general invoice is not found to creating upcoming invoice"
  #     return
  #   end
  # end

  # def get_valid_amount_rental_invoice
  #   self.payment_agreement.rental_invoices.each do |rental_invoice|
  #     if self.next_invoice_due_date >= rental_invoice.start_date.to_date && self.next_invoice_due_date.to_date <= rental_invoice.end_date.to_date
  #       self.valid_amount_invoice = rental_invoice
  #       return
  #     end
  #   end
  #   # No agreement invoice is found with next_invoice_due_date in between start date and end date  
  #   if self.valid_amount_invoice.blank?
  #     add_message :error, "Valid amount rental invoice is not found to creating upcoming invoice"
  #     return
  #   end
  # end


  def create_upcoming_invoice
    
  end

  def first_invoice_start_date
    first_fixed_periodic_invoice.start_date
  end

  def first_invoice_end_date
    first_fixed_periodic_invoice.end_date
  end

  def invoice_frequency_based_end_date(invoice_start_date, invoice_frequency)
    if invoice_frequency == 1
      return invoice_start_date.end_of_month
    else
      return (invoice_start_date + invoice_frequency.month-1.month).end_of_month
    end
  end

  def setup_invoice_params
    reference_invoice = get_reference_invoice
    invoice_frequency = get_invoice_frequency(self.invoice_type)
    due_date = get_invoice_due_date(reference_invoice)
    invoice_params = {
      start_date: first_start_date,
      end_date: first_reference_invoice.end_date, #upcoming_invoice_end_date(upcoming_invoice_start_date, invoice_frequency),
      vendor_id: reference_invoice.vendor_id,
      department_id: reference_invoice.department_id,
      location_id: reference_invoice.location_id,
      cost_center_id: reference_invoice.cost_center_id,
      payment_term_id: reference_invoice.payment_term_id,
      note: reference_invoice.note,
      billing_type_id: reference_invoice.billing_type_id,
      due_date: due_date,
      tax_type_id: reference_invoice.tax_type_id,
      discount_type_id: reference_invoice.discount_type_id,
      gross_amount: get_gross_amount(reference_invoice.gross_amount),
      net_amount: get_net_amount(reference_invoice.net_amount),
      amount: get_amount(reference_invoice.amount),
      discount_amount: get_discount_amount(reference_invoice.discount_amount),
      tds_amount: get_tds_amount(reference_invoice.tds_amount),
      tax_amount: get_tax_amount(reference_invoice.tax_amount),
      original_amount: get_original_amount(reference_invoice.original_amount),
      advance_amount: get_advance_amount(reference_invoice.advance_amount),
      balance_due: get_balance_due(reference_invoice.balance_due),
      taxable_amount: get_taxable_amount(reference_invoice.taxable_amount),
      company_id: reference_invoice.company_id,
      created_by_user_id: reference_invoice.created_by_user_id,
      payment_agreement_id: reference_invoice.payment_agreement_id,
      bank_account_id: reference_invoice.bank_account_id,
      vendor_location_id: reference_invoice.vendor_location_id,
      prepaid: reference_invoice.prepaid,
      invoice_frequency_id: reference_invoice.invoice_frequency_id, # TODO - Remove is whenever invoice is editable, its referencing same record
      fixed_periodic_template: true,
      payment_agreement_upcoming_date: get_payment_agreement_upcoming_date(reference_invoice, upcoming_invoice_start_date, upcoming_invoice_end_date(upcoming_invoice_start_date, invoice_frequency), reference_invoice.prepaid),
      is_payment_agreement_upcoming_invoice: check_if_upcoming_invoice(reference_invoice, upcoming_invoice_start_date, upcoming_invoice_end_date(upcoming_invoice_start_date, invoice_frequency), reference_invoice.prepaid)
    }
    return invoice_params
  end

  # def setup_next_invoice_params
  # end

  def first_fixed_periodic_invoice
    self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.order(:start_date).first
  end

  # TODO -  change this
  def get_invoice_due_date(first_reference_invoice)
    if first_reference_invoice.present?
      if first_reference_invoice.payment_term.days_after.present?
        if first_reference_invoice.prepaid
          due_date = first_reference_invoice.start_date + first_reference_invoice.payment_term.days_after
        else
          due_date = first_reference_invoice.end_date + first_reference_invoice.payment_term.days_after
        end
      else
        add_message :error, "Configuration issue, payment term is incorrect"
        return
      end
    else
      # For next invoice
    end
    return due_date
  end

  def get_reference_invoice
    if self.first_reference_invoice.present?
      first_reference_invoice
    else
      next_reference_invoice
    end
  end

  def next_reference_invoice
    escalated_reference_invoice.present? ? escalated_reference_invoice : previous_upcoming_invoice
  end

  def upcoming_invoice_start_date
    # First invoice start date or next start of month for previous_upcoming_invoice 
    first_reference_invoice.present? ? first_reference_invoice.start_date : previous_upcoming_invoice.end_date + 1
  end

  def upcoming_invoice_end_date(invoice_start_date, invoice_frequency)
    invoice_frequency_based_end_date(invoice_start_date, invoice_frequency)
  end

  def get_gross_amount(amount)
    create_invoice_amount(amount)
  end

  def get_net_amount(amount)
    create_invoice_amount(amount)
  end

  def get_amount(amount)
    create_invoice_amount(amount)
  end

  def get_discount_amount(amount)
    # create_invoice_amount(amount)
  end

  def get_tds_amount(amount)
    create_invoice_amount(amount)
  end

  def get_tax_amount(amount)

  end

  def get_original_amount(amount)
  end

  def get_advance_amount(amount)
  end

  def get_balance_due(amount)
  end

  def get_taxable_amount(amount)
  end

  def get_payment_agreement_upcoming_date(reference_invoice, start_date, end_date, prepaid)
    # return start_date # FOR TESTING ONLY
    prepaid ? first_start_date : end_date
  end

  def check_if_upcoming_invoice(reference_invoice, start_date, end_date, prepaid)
    # return true # FOR TESTING ONLY
    prepaid ? first_start_date <= Date.today : end_date <= Date.today
  end

  def create_invoice_amount(amount)
    Amount.create(value: amount.value, currency_id: amount.currency_id)
  end

  def get_effective_days_count(invoice_start_date, invoice_end_date, actual_end_date, one_month_rate)

  end

end