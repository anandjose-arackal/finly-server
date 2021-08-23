class PaymentAgreements::Submit < PaymentAgreements::Base

  attr_accessor :payment_agreement

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
      return
    end

    if payment_agreement.general_invoices.blank? && payment_agreement.beneficiary_payments.blank? && payment_agreement.security_deposits.blank? && payment_agreement.rental_invoices.blank?
      add_message :error, 'Please add atleast one agreement item'
    end
  end

  def process
    params[:document] = self.payment_agreement
    params[:aasm_event] = 'submit'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.payment_agreement.update(reject_note: nil)
    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "You've approved the agreement"
    if self.payment_agreement.status_id == PaymentAgreementStatus.id_for(:auto_approved)
     agreement_related_operations
    end
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