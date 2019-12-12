# This operation is used for creating upcoming invoices for fixed periodic invoice
# Fixed periodic invoice can have multiple invoices generated within the start_date and end_date range
# Invoice freqency is allowed to be monthy only, hence considering 'month' as default period
class PaymentAgreements::CreateUpcomingInvoice < PaymentAgreements::Base

  attr_accessor :payment_agreement, :previous_upcoming_invoice, :next_invoice_due_date, :valid_amount_invoice, :new_upcoming_invoices, :invoice_type, :vendor_id, :escalated_reference_invoice, :effective_end_date, :reference_invoice_type, :upcoming_invoice_params, :reference_invoice_ids, :base_start_date, :current_month_end_date, :count, :ordered_upcoming_invoice_dates

  def init
    payment_agreement_id = params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id payment_agreement_id
    self.reference_invoice_type = params[:reference_invoice_type]
    self.invoice_type = params[:reference_invoice_type]
    self.vendor_id = params[:vendor_id]
    self.reference_invoice_ids = params[:reference_invoice_ids]
    self.upcoming_invoice_params = []
    self.base_start_date = Date.parse("01 Aug 2019")
    self.current_month_end_date = get_current_month_end_date #Date.today.end_of_month
    self.count = 1
    self.ordered_upcoming_invoice_dates = {}
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

    if reference_invoice_type.blank?
      add_message :error, "Reference invoice type cannot be blank"
    end

    if payment_agreement.terminated?
      add_message :error, 'Payment Agreement has been terminated, unable to create upcoming invoices'
    end
  end

  def process
    case reference_invoice_type.camelize
    when "GeneralInvoice"
      create_upcoming_general_invoice
    when "RentalInvoice"
      create_upcoming_rental_invoice
    end
  end

  def success
    params[:new_upcoming_invoices] = self.new_upcoming_invoices
    PaymentAgreements::CreateUpcomingInvoice::CreateUpcomingInvoicePresenter.new(user, params, messages)
  end

  class PaymentAgreements::CreateUpcomingInvoice::CreateUpcomingInvoicePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :new_upcoming_invoices

    def init
      self.new_upcoming_invoices = params[:new_upcoming_invoices]
    end

  end

  def create_upcoming_general_invoice
    upcoming_invoice_parameters = generate_upcoming_invoice_params(reference_invoice_ids, 'general_invoice')
    self.new_upcoming_invoices = user.company.general_invoices.create(upcoming_invoice_parameters)
    # InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, invoice)
    if self.new_upcoming_invoices.blank?
      add_message :error, 'Some error occurred during generation of upcoming general invoice'
    end
    self.new_upcoming_invoices.each do |invoice|
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, invoice)
      unless invoice.save
        add_message :error, 'Some error occurred during calculation'
        return
      end
    end
  end

  def create_upcoming_rental_invoice
    upcoming_invoice_parameters = generate_upcoming_invoice_params(reference_invoice_ids, 'rental_invoice')
    self.new_upcoming_invoices = user.company.rental_invoices.create(upcoming_invoice_parameters)
    # InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, invoice)
    if self.new_upcoming_invoices.blank?
      add_message :error, 'Some error occurred during generation of upcoming rental invoice'
    end
    self.new_upcoming_invoices.each do |invoice|
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts({}, nil, invoice)
      unless invoice.save
        add_message :error, 'Some error occurred during calculation'
        return
      end
    end
  end

  def setup_invoice_params(options={})
    invoice_params = {
      start_date: options[:invoice_start_date],
      end_date: options[:invoice_end_date],
      vendor_id: options[:vendor_id],
      department_id: options[:department_id],
      location_id: options[:location_id],
      cost_center_id: options[:cost_center_id],
      payment_term_id: options[:payment_term_id],
      #note: ,
      billing_type_id: options[:billing_type_id],
      due_date: options[:due_date],
      tax_type_id: options[:tax_type_id],
      discount_type_id: options[:discount_type_id],
      gross_amount: options[:gross_amount],
      net_amount: options[:net_amount],
      amount: options[:amount],
      discount_amount: options[:discount_amount],
      tds_amount: options[:tds_amount],
      tax_amount: options[:tax_amount],
      original_amount: options[:original_amount],
      advance_amount: options[:advance_amount],
      balance_due: options[:balance_due],
      taxable_amount: options[:taxable_amount],
      company_id: options[:company_id],
      created_by_user_id: options[:created_by_user_id],
      payment_agreement_id: self.payment_agreement.id,
      bank_account_id: options[:bank_account_id],
      vendor_location_id: options[:vendor_location_id],
      prepaid: options[:prepaid],
      invoice_frequency_id: options[:invoice_frequency_id],
      fixed_periodic_template: options[:fixed_periodic_template],
      payment_agreement_upcoming_date: options[:payment_agreement_upcoming_date],
      is_payment_agreement_upcoming_invoice: options[:is_payment_agreement_upcoming_invoice],
      tds_slab_id: options[:tds_slab_id],
      invoice_items_attributes: get_invoice_item_params(options[:invoice_start_date], options[:invoice_end_date])
    }
  end

  def get_invoice_item_params(start_date, end_date)
    invoice_item_params = []
    reference_invoices = get_reference_invoices
    # Reference invoices that are valid for the date range from start date to end date
    effective_start_date = get_reference_invoices.where("DATE(start_date) <= ?", start_date).order(:start_date).last.start_date
    effective_start_date = (effective_start_date < start_date) ? effective_start_date : start_date
    # effective_end_date = get_reference_invoices.where("DATE(end_date) >= ?", start_date).order(:end_date).last.end_date
    reference_invocies_in_range = get_reference_invoices_in_range(effective_start_date, current_month_end_date)
    # reference_invocies_in_range = get_reference_invoices_in_range(base_start_date, current_month_end_date) # TODO change
    # Initial reference invoice is used to get the common attributes line department, location etc
    initial_reference_invoice = reference_invocies_in_range.first
    # All rerefernce invoices will have same items in line items
    initial_reference_invoice.invoice_items.each do |invoice_item|
      item_params = invoice_item_params_data(initial_reference_invoice, invoice_item, start_date, end_date)
      invoice_item_params.push(item_params)
    end
    return invoice_item_params
  end

  def invoice_item_params_data(initial_reference_invoice, invoice_item, start_date, end_date)
    {
      description: invoice_item.description,
      quantity: invoice_item.quantity,
      rate: calculate_item_rate(start_date, end_date, invoice_item),
      tax: invoice_item.tax,
      discount: invoice_item.discount,
      category_id: invoice_item.inventory_line_item.category_id,
      gst_type_id: invoice_item.gst_type_id,
      hsn_sac: invoice_item.inventory_line_item.hsn_sac,
      parent_type: initial_reference_invoice.class.name,
      # parent_id:
      inventory_line_item_id: invoice_item.inventory_line_item_id,
      # item_info:
      account: invoice_item.account,
      tax_rate_id: invoice_item.tax_rate_id,
      cost_center_id: invoice_item.cost_center_id,
      unit_of_measurement: invoice_item.unit_of_measurement,
      department_id: invoice_item.department_id,
      sgst: invoice_item.sgst,
      cgst: invoice_item.cgst,
      igst: invoice_item.igst#,
      # Entities to be cloned to avoid single reference. Editing single reference will edit it for all places where is it pointed to. Hence AVOID!!
      # TODO -  Update these fields using invoice calculation util

      # tax_amount_id: get_item_tax_amount(invoice_item.tax_amount),
      # discount_amount_id: get_item_discount_amount(invoice_item.discount_amount),
      # amount_id: get_item_amount()
      # net_amount_id:
      # taxable_amount_id:
      # billable_amount_id:
    }
  end

  def calculate_item_rate(start_date, end_date, invoice_item)
    effective_start_date = get_reference_invoices.where("DATE(start_date) <= ?", start_date).order(:start_date).last.start_date
    effective_start_date = (effective_start_date < start_date) ? effective_start_date : start_date
    # reference_invocies_in_range = get_reference_invoices_between_dates(start_date, end_date)
    # if reference_invocies_in_range.blank?
      reference_invocies_in_range = get_reference_invoices_in_range(effective_start_date, current_month_end_date)
    # end
    reference_invoice = reference_invocies_in_range.where(start_date: start_date).first
    if reference_invoice.blank?
      reference_invoice = reference_invocies_in_range.where(end_date: end_date).first
    end
    if reference_invoice.blank?
      reference_invoice = reference_invocies_in_range.where("DATE(start_date) <= ?", start_date).order(:start_date).last
    end
    if reference_invoice.blank?
      reference_invoice = reference_invocies_in_range.where("DATE(end_date) <= ?", end_date).order(:start_date).first
    end
    # reference_invocies_in_range.each do |reference_invoice|
      # Do not allow multiple line item of similar inventory, else this will fail
      item = reference_invoice.items.where(inventory_line_item_id: invoice_item.inventory_line_item_id).first
      # if reference_invoice.start_date <= start_date && reference_invoice.end_date >= end_date
      #   return rate = item.rate
      # else
        # days_in_month = (end_date.end_of_month - start_date.beginning_of_month).to_i + 1
        days_in_month = ((start_date.beginning_of_month + reference_invoice.invoice_frequency.number.month) - start_date.beginning_of_month)
        # Example: Invoice frequency is 1 month. Upcoming invoice is for Aug 2019. If reference invoice template has invoice start date as 26 Sept 2019 and invoice end date as 9 Aug 2019, then effective days for the Aug invoice is 01 Aug to 09 Aug 2019. Base condition: Invoice starts from start of month and ends on end_of_month(excluding first and last invoice)
        effective_days_count = (end_date - start_date).to_i + 1
        # In months
        invoice_occurance_rate = reference_invoice.invoice_frequency.number
        one_month_rate = item.rate/reference_invoice.invoice_frequency.number
        effective_rate = (item.rate/days_in_month)*effective_days_count
        return ActionController::Base.helpers.number_with_precision(effective_rate, precision: 2)
      # end
    # end
  end

  def setup_invoice_items_params(options={})
  end

  def get_reference_invoices_between_dates(start_date, end_date)
    get_reference_invoices.where("DATE(start_date) = ? AND DATE(end_date) = ?", start_date, end_date)
  end

  def get_reference_invoices_in_range(start_date, end_date)
    get_reference_invoices.where("DATE(start_date) >= ? AND DATE(start_date) <= ?", start_date, end_date)
  end



  def get_reference_invoices
    self.payment_agreement.send(invoice_type.pluralize.to_sym).where(id: reference_invoice_ids).order(:start_date)
  end

  def get_due_date(start_date, end_date, prepaid, payment_term_days)
      prepaid ? start_date + payment_term_days : end_date + payment_term_days
  end

  def get_payment_agreement_upcoming_date(start_date, end_date, prepaid)
    # return start_date # FOR TESTING ONLY
    prepaid ? start_date : (end_date + 1)
  end

  def create_invoice_amount(amount)
    Amount.create(value: amount.value, currency_id: amount.currency_id)
  end

  def generate_upcoming_invoice_params(reference_invoice_ids, invoice_type)
    reference_invoices = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(id: reference_invoice_ids).order(:start_date)
    invoice_frequency_number = reference_invoices.first.invoice_frequency.number
    initial_start_date = reference_invoices.first.start_date
    # upcoming_invoices_count = get_upcoming_invoice_count(invoice_frequency_number, initial_start_date, current_month_end_date)
    upcoming_invoice_dates = get_upcoming_invoice_dates(invoice_frequency_number, initial_start_date, current_month_end_date, reference_invoices)
    options = {
      # invoice_frequency_number: invoice_frequency_number,
      # initial_start_date: initial_start_date,
      # current_month_end_date: current_month_end_date,
      upcoming_invoice_dates: upcoming_invoice_dates.values
    }
    return setup_upcoming_invoices_params(reference_invoice_ids, options)
  end

  def setup_upcoming_invoices_params(reference_invoice_ids, options={})
    # This invoice gets common values like department location etc
    initial_reference_invoice = self.payment_agreement.send(invoice_type.pluralize.to_sym).where(id: reference_invoice_ids).order(:start_date).first
    upcoming_invoice_dates = options[:upcoming_invoice_dates]
    upcoming_invoice_dates.each do |upcoming_invoice_date|
      options[:invoice_start_date] = upcoming_invoice_date[0]
      options[:invoice_end_date] = upcoming_invoice_date[1]
      options[:vendor_id] = self.vendor_id
      options[:department_id] = initial_reference_invoice.department_id
      options[:location_id] = initial_reference_invoice.location_id
      options[:cost_center_id] = initial_reference_invoice.cost_center_id
      options[:payment_term_id] = initial_reference_invoice.payment_term_id
      options[:billing_type_id] = initial_reference_invoice.billing_type_id
      options[:prepaid] = initial_reference_invoice.prepaid
      options[:due_date] = get_due_date(upcoming_invoice_date[0], upcoming_invoice_date[1], initial_reference_invoice.prepaid, initial_reference_invoice.payment_term.days_after)
      options[:tax_type_id] = initial_reference_invoice.tax_type_id # TODO check
      options[:discount_type_id] = initial_reference_invoice.discount_type_id
      # options[:gross_amount] = get_gross_amount(initial_reference_invoice.gross_amount) # TODO check
      # options[:net_amount] = get_net_amount(initial_reference_invoice.net_amount) # TODO check
      # options[:amount] = get_amount(initial_reference_invoice.amount) # TODO check
      # options[:discount_amount] = get_discount_amount(initial_reference_invoice.discount_amount) #TODO check
      # options[:tds_amount] = get_tds_amount(initial_reference_invoice.tds_amount) # TODO check
      # options[:tax_amount] = get_tax_amount(initial_reference_invoice.tax_amount) # TODO check
      # options[:original_amount] = get_original_amount(initial_reference_invoice.original_amount) # TODO check
      # options[:advance_amount] = get_advance_amount(initial_reference_invoice.advance_amount) # TODO checl
      # options[:balance_due] = get_balance_due(initial_reference_invoice.balance_due) # TODO check
      # options[:taxable_amount] = get_taxable_amount(initial_reference_invoice.taxable_amount) # TODO check
      options[:company_id] = initial_reference_invoice.company_id
      options[:created_by_user_id] = self.payment_agreement.creator_id # Some invoices will be auto generated, hence autogeneration should be set true
      options[:payment_agreement_id] = initial_reference_invoice.payment_agreement_id
      options[:bank_account_id] = initial_reference_invoice.bank_account_id
      options[:vendor_location_id] = initial_reference_invoice.vendor_location_id
      options[:prepaid] = initial_reference_invoice.prepaid
      options[:invoice_frequency_id] = dup_invoice_frequency(initial_reference_invoice.invoice_frequency)
      options[:fixed_periodic_template] = true
      options[:payment_agreement_upcoming_date] = get_payment_agreement_upcoming_date(upcoming_invoice_date[0], upcoming_invoice_date[1], initial_reference_invoice.prepaid)
      options[:is_payment_agreement_upcoming_invoice] = true
      options[:tds_slab_id] = initial_reference_invoice.tds_slab_id
      self.upcoming_invoice_params.push(setup_invoice_params(options))
    end
    return upcoming_invoice_params
  end

  def get_upcoming_invoice_count(invoice_frequency_number, start_date, end_date)
    months_count = month_between_dates(start_date, end_date)
    upcoming_invoices_count = months_count.zero? ? 0 : months_count.fdiv(invoice_frequency_number).ceil
  end

  
  # Invoices are be generated at the end of the month
  # Irrespective or prepaid/postpaid, this will have date range of all invoices created
  # This upcoming date is till current month for prepaid 
  def get_upcoming_invoice_dates(invoice_frequency_number, start_date, end_date, reference_invoices)
    # ordered_upcoming_invoice_dates key is for sorting. Helps to find which invoice is to be generated first
    # First start date
    initial_start_date = start_date
    # Last end date can before current month
    i_end_date = reference_invoices.where("(Date(start_date) >= ? AND DATE(start_date) <= ?) OR (Date(end_date) >= ? AND DATE(end_date) <= ?)", start_date, end_date, start_date, end_date).order(:start_date).last.end_date
     last_end_date = (i_end_date <= end_date) ? i_end_date : end_date
    months_count = month_between_dates(start_date, end_date)
    invoice_frequency_number = reference_invoices.first.invoice_frequency.number # In months
    # Break the loop if last end date is reached
    # Counter for order of invoice
    (1..months_count).to_a.each do |counter|
      #For first invoice(start date is not start of month)
      # if counter == 1
      #   # Start date will always be first of month except for first invoice
      #   invoice_start_date = initial_start_date
      #   # End date will always be last of month except for last invoice
      #   invoice_end_date =  (initial_start_date + invoice_frequency_number.month - 1).end_of_month <= last_end_date ? (initial_start_date + invoice_frequency_number.month - 1).end_of_month : last_end_date
      #   # Override above start date end end date as there can be escalation within invoice frequency period
      #   # This will help find if there is escalation in the frequency range
      #     upcoming_invoice_date = get_upcoming_invoice_start_end_date(invoice_start_date, invoice_end_date)
      #     self.count += 1
      #     ordered_upcoming_invoice_dates[count] = upcoming_invoice_date
      #     break if upcoming_invoice_date >= last_end_date
      #   end
      # else
        if counter == 1
          invoice_start_date = initial_start_date
        else
          prev_start_date = ordered_upcoming_invoice_dates.fetch(ordered_upcoming_invoice_dates.keys.sort.last)[0]
          prev_end_date = ordered_upcoming_invoice_dates.fetch(ordered_upcoming_invoice_dates.keys.sort.last)[1]
          invoice_start_date = prev_end_date + 1
        end


        invoice_end_date =  (invoice_start_date + invoice_frequency_number.month - 1.month).end_of_month <= last_end_date ? (invoice_start_date + invoice_frequency_number.month - 1.month).end_of_month : last_end_date
        get_upcoming_invoice_start_end_date(invoice_start_date, invoice_end_date, reference_invoices)
        break if ordered_upcoming_invoice_dates.fetch(ordered_upcoming_invoice_dates.keys.sort.last)[1] >= last_end_date
      # end
    end
    ordered_upcoming_invoice_dates
  end

  def get_upcoming_invoice_start_end_date(start_date, end_date, reference_invoices)
    invoice_dates = reference_invoices.where("(Date(start_date) >= ? AND DATE(start_date) <= ?) OR (Date(end_date) >= ? AND DATE(end_date) <= ?)", start_date, end_date, start_date, end_date).collect{|i| [i.start_date, i.end_date]}
    i_start_date = start_date
    if invoice_dates.blank?
      self.ordered_upcoming_invoice_dates[count] = [start_date, end_date]
      self.count += 1
    else
      invoice_dates.each do |date_range|
        s_date = i_start_date
        e_date = date_range[1]
        if e_date > end_date
          e_date = end_date
        end
        self.ordered_upcoming_invoice_dates[count] = [s_date, e_date]
        self.count += 1
        i_start_date = e_date + 1
      end
    end
    return ordered_upcoming_invoice_dates
  end

  def order_of_month(start_date, end_date)
    months_count = month_between_dates(start_date, end_date)
    start_date_month = start_date.month
    months = []
    (1..months_count).to_a.each do |counter|
      months << start_date_month
      start_date_month += 1
    end
    months
  end

  def validate_start_and_end_date(start_date, end_date)
    if start_date > end_date
      add_message :error, 'Start date cannot be greater than end date'
      return
    end
  end 


  # Inclusive of current month
  def month_between_dates(start_date, end_date)
    if end_date >= start_date
      ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) + 1)
    else
      add_message :error, 'End date cannot be less than start date'
    end
  end

  def dup_invoice_frequency(invoice_frequency)
    new_invoice_frequency = invoice_frequency.dup
    unless new_invoice_frequency.save
      add_message :error, 'Some error occurred while duplicating the frequency'
      return nil
    end
    new_invoice_frequency.id
  end

  def get_current_month_end_date
    reference_invoices = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(id: reference_invoice_ids).order(:start_date)
    initial_start_date = reference_invoices.first.start_date
    invoice_frequency_number = reference_invoices.first.invoice_frequency.number
    # Find out the end date
    # Base assumption - 20 is the max distance w.r.t. frequency
    valid_end_date = nil
    start_date = initial_start_date
    (1..20).each do |counter|
      next_date = (start_date + invoice_frequency_number.month - 1.month).end_of_month
      if next_date >= Date.today.end_of_month
        valid_end_date = next_date
        break
      end
      start_date = next_date + 1
    end
    valid_end_date
  end

end