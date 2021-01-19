class Procurements::PurchaseRequests::Retract < Procurements::PurchaseRequests::Base

  def process
    params[:document] = self.purchase_request
    params[:aasm_event] = 'retract'

    op = WorkflowManager::Base.(user, params)

    if op.success?
      # Retract the line items too
      purchase_request.purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(purchase_request.status.name.to_sym))
    else
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