class Procurements::PurchaseRequests::Approve < Procurements::PurchaseRequests::Base
  def process
    #TODO: Put this whole process in active record base transaction
    params[:document] = self.purchase_request
    params[:aasm_event] = 'approve'

    op = WorkflowManager::Base.(user, params)
    if op.success?
      # Approve non-rejected line items
      self.purchase_request.purchase_request_items.non_rejected.each do |item|
        params[:document] = item
        params[:aasm_event] = 'approve'

        op = WorkflowManager::Base.(user, params)
      end if self.purchase_request.purchase_request_items.present?
    else
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "Purchase request approved"
  end
end