class Procurements::PurchaseRequests::Retract < Procurements::PurchaseRequests::Base

  def process
    self.purchase_request.paper_trail_event = "Retract"
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
    Event::EPurchaseRequest::Retract.(user, purchase_request: purchase_request, workflow_output: workflow_output)
    add_message :success, "Purchase request retracted"
  end
end