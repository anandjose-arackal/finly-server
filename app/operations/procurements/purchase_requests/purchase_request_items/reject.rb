class Procurements::PurchaseRequests::PurchaseRequestItems::Reject < Procurements::PurchaseRequests::PurchaseRequestItems::Base

  def process
    # params[:document] = self.purchase_request_item
    # params[:aasm_event] = 'reject'

    # op = WorkflowManager::Base.(user, params)
    # unless op.success?
    #   add_message :error, op.messages[:error]
    #   return
    # end

    # self.workflow_output = op.workflow_output


    # Do not change status of anything fails
    self.purchase_request_item.status_id = PurchaseRequestItemStatus.id_for(:rejected)
    self.purchase_request_item.rejected = true
    self.purchase_request_item.save
  end

  def post_process
    add_message :success, "You've rejected reviewal of purchase request"
  end
end