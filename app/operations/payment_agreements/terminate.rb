class PaymentAgreements::Terminate < PaymentAgreements::Base
  attr_accessor :payment_agreement, :termination_reason

  def init
    self.payment_agreement = PaymentAgreements::Show.(user, params).payment_agreement
    self.termination_reason = params[:termination_reason]
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
      return
    end
    if params[:termination_reason].blank?
      add_message :error, 'Please add reason for termiation of this agreement'
    end
  end

  def process
    params[:document] = self.payment_agreement
    params[:aasm_event] = 'terminate'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    update_termination_details
    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "You've successfully terminated the agreement"
  end

  def update_termination_details
    self.payment_agreement.terminated_at = DateTime.now
    self.payment_agreement.termination_reason = self.termination_reason
    self.payment_agreement.terminated_by_id = user.id
    self.payment_agreement.save
  end
  
end