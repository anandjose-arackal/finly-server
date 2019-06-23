class PaymentAgreements::Submit < PaymentAgreements::Base

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
    params[:document] = self.payment_agreement
    params[:aasm_event] = 'submit'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "You've submitted the agreement"
  end
  
end