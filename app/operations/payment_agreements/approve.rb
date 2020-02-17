class PaymentAgreements::Approve < PaymentAgreements::Base

  attr_accessor :payment_agreement

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
    end
  end

  def process
    # agreement_related_operations
    # return
    params[:document] = self.payment_agreement
    params[:aasm_event] = 'approve'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    agreement_related_operations
    add_message :success, "You've approved the agreement"
  end

  def agreement_related_operations
    if self.payment_agreement.approved?
      update_one_time_invoice
      if self.payment_agreement.general_invoices.fixed_periodic_type.present? || self.payment_agreement.rental_invoices.fixed_periodic_type.present?
        params[:payment_agreement_id] = self.payment_agreement.id
        upcoming_invoice_op = ::PaymentAgreements::CreateUpcomingInvoiceBackground.call(user, {payment_agreement_id: self.payment_agreement.id})
      end
    end
  end

  # # After approval, upcoming invoices till date are created
  # # Base date is 01 Aug 2019. Invoice cannot be before this date
  # def create_upcoming_invoice(vendor_id, invoice_type)
  #   execution_date = self.payment_agreement.execution_date.to_date
  #   if self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id).where("Date(start_date) >= ? AND DATE(start_date) <= ?", Date.parse("01 Aug 2019"), Date.today.end_of_month).present?
  #     reference_invoice_ids = self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id).where("Date(start_date) >= ? AND DATE(start_date) <= ?", Date.parse("01 Aug 2019"), Date.today.end_of_month).pluck(:id)
  #     params[:reference_invoice_ids] = reference_invoice_ids
  #     params[:vendor_id] = vendor_id
  #     params[:reference_invoice_type] = invoice_type
  #     params[:payment_agreement_id] = self.payment_agreement.id
  #     upcoming_invoice_op = ::PaymentAgreements::CreateUpcomingInvoice.(user, params)
  #     unless upcoming_invoice_op.success?
  #       add_message :error, "Error occurred, 1 or more upcoming invoices are not created"
  #       return
  #     end

  #     # self.payment_agreement.send(invoice_type.pluralize.to_sym).fixed_periodic_type.where(vendor_id: vendor_id).where("Date(start_date) >= ? AND DATE(start_date) <= ?", Date.parse("01 Aug 2019"), Date.today.end_of_month).order(:start_date).each_with_index do |agreement_invoice, index|
  #     # end
  #   end
  # end

  def update_one_time_invoice
    if self.payment_agreement.general_invoices.one_time_type.present?
      update_upcoming_date('general_invoices')
      self.payment_agreement.general_invoices.one_time_type.update_all(is_payment_agreement_upcoming_invoice: true)
    end

    if self.payment_agreement.rental_invoices.one_time_type.present?
      update_upcoming_date('rental_invoices')
      self.payment_agreement.rental_invoices.one_time_type.update_all(is_payment_agreement_upcoming_invoice: true)
    end
  end

  def update_upcoming_date(invoice_type)
    self.payment_agreement.send(invoice_type.pluralize.to_sym).one_time_type.each do |invoice_template|
      date = invoice_template.prepaid ? invoice_template.start_date : invoice_template.end_date
      invoice_template.update(payment_agreement_upcoming_date: date)
    end
  end


end