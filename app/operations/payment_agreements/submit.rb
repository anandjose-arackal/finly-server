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

    # Rental should not submit without security deposit
    if self.payment_agreement.rental_invoices.present?
      if self.payment_agreement.security_deposits.blank?
        add_message :error, 'Please add and update security deposit with rental invoice'
      end
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
    add_message :success, "You've submitted the agreement"
  end
  
end