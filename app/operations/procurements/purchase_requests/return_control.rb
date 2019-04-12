class Procurements::PurchaseRequests::ReturnControl < Procurements::PurchaseRequests::Base

  def process
    params[:document] = self.purchase_request
    params[:aasm_event] = 'return_control'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "You've returned control of purchase request"
  end
end