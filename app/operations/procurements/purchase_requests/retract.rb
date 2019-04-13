class Procurements::PurchaseRequests::Retract < Procurements::PurchaseRequests::Base

  def process
    params[:document] = self.purchase_request
    params[:aasm_event] = 'retract'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "Purchase request retracted"
  end
end