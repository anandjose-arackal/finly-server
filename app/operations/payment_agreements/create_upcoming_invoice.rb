class PaymentAgreements::CreateUpcomingInvoice < PaymentAgreements::Base

  
  # :valid_amount_invoice =>  is the invoice for which next_invoice_due_date falls between its start date and end date
  # :partial_invoice_ids => It contains  id if invoice that will be generated at last and its upcoming date falls after expiration date due to invoice_frequency
  # :new_upcoming_invoice => Upcoming invoice that  act as a template for the new actual invoice
  attr_accessor :payment_agreement, :agreement_invoice, :partial_invoice_ids, :next_invoice_due_date, :valid_amount_invoice, :new_upcoming_invoice

  def init
    payment_agreement_id = params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id payment_agreement_id
    self.agreement_invoice = params[:previous_upcoming_invoice]
    self.partial_invoice_ids = []
  end

  def validate
    if self.payment_agreement.blank?
      add_message :error, "Agreement not present while creating upcoming invoice"
      return
    end
    if self.agreement_invoice.blank?
      add_message :error, "General and rental invoice both are not found"
      return
    end
    # Upcoming invoice creation is only allowed for agreement invoices with billing type fixed period
    unless self.agreement_invoice.billing_type.fixed_periodic?
      add_message :error, "Only fixed periodic agreement invoices can be auto-created"
      return
    end
    # If expiration date of agreement is in future, or no_expiration then only allow to create upcoming invoices
    unless self.payment_agreement.no_expiration || self.payment_agreement.expiration_date.to_date >= Date.today
      add_message :error, "Agreement is already expired!"
      return
    end
    # Invoice frequency should not cross expiration date of payment agreement
    next_upcoming_invoice_required(agreement_invoice)
  end

  def process
    case self.agreement_invoice.class.name
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

  def next_upcoming_invoice_required(previous_upcoming_invoice)
    invoice_upcoming_date(previous_upcoming_invoice)
    if self.next_invoice_due_date.blank?
      add_message :error, "Period or upcoming date is not defined for #{previous_upcoming_invoice.class.name.titleize} "
      return
    end

    unless self.payment_agreement.no_expiration 
      if self.next_invoice_due_date.to_date > self.payment_agreement.expiration_date.to_date
        # Keep this partial invoice ids for future reference as this condition is not currently handled
        self.partial_invoice_ids.push(agreement_invoice.id)
        add_message :error, 'Next upcoming invoice due date cannot be after agreement expiration'
        return
      end
    end
    true
  end

  # Return next upcoming date w.r.t the previous invoice and that will be previous invoice upcoming date + invoice frequency - 1 day
  # 1 month is complete when same date arrives in the next month
  def invoice_upcoming_date(previous_upcoming_invoice)
    number = previous_upcoming_invoice.invoice_frequency.number
    period_id = previous_upcoming_invoice.invoice_frequency.period_id
    case period_id
    when Period.id_for(:month)
      self.next_invoice_due_date = previous_upcoming_invoice.payment_agreement_upcoming_date.to_date + number.to_i.month - 1.day
      return
    end
    return nil
  end

  # Check which invoice hold next_invoice_due_date between start date and end date
  # Duplicate that invoice, this duplicated invoice will be new upcoming_invoice
  # This is valid only for fixed periodic invoices
  def create_upcoming_general_invoice
    get_valid_amount_general_invoice
    if self.valid_amount_invoice.present?
      upcoming_general_invoice = self.valid_amount_invoice.amoeba_dup
      upcoming_general_invoice.template_invoice_id = self.valid_amount_invoice.id
      unless upcoming_general_invoice.save
        add_message :error, "Unable to create upcoming general invoice"
        return
      end
      self.new_upcoming_invoice = upcoming_general_invoice
    end
  end

  def create_upcoming_rental_invoice
    get_valid_amount_rental_invoice
    if self.valid_amount_invoice.present?
      upcoming_rental_invoice = self.valid_amount_invoice.amoeba_dup
      upcoming_rental_invoice.template_invoice_id = self.valid_amount_invoice.id
      unless upcoming_rental_invoice.save
        add_message :error, "Unable to create upcoming general invoice"
        return
      end
      self.new_upcoming_invoice = upcoming_rental_invoice
    end
  end

  def get_valid_amount_general_invoice
    self.payment_agreement.general_invoices.each do |general_invoice|
      if self.next_invoice_due_date >= general_invoice.start_date.to_date && self.next_invoice_due_date.to_date <= general_invoice.end_date.to_date
        self.valid_amount_invoice = general_invoice
        return
      end
    end
    # No agreement invoice is found with next_invoice_due_date in between start date and end date  
    if self.valid_amount_invoice.blank?
      add_message :error, "Valid amount general invoice is not found to creating upcoming invoice"
      return
    end
  end

  def get_valid_amount_rental_invoice
    self.payment_agreement.rental_invoices.each do |rental_invoice|
      if self.next_invoice_due_date >= rental_invoice.start_date.to_date && self.next_invoice_due_date.to_date <= rental_invoice.end_date.to_date
        self.valid_amount_invoice = rental_invoice
        return
      end
    end
    # No agreement invoice is found with next_invoice_due_date in between start date and end date  
    if self.valid_amount_invoice.blank?
      add_message :error, "Valid amount rental invoice is not found to creating upcoming invoice"
      return
    end
  end


  def create_upcoming_invoice
    
  end


end