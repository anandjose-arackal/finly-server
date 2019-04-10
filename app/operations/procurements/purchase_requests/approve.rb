class Procurements::PurchaseRequests::Approve < Procurements::PurchaseRequests::Base
  def process
    # #TODO: Put this whole process in active record base transaction
    # params[:document] = self.purchase_request
    # params[:aasm_event] = 'approve'

    # op = WorkflowManager::Base.(user, params)
    # if op.success?
    #   # Approve non-rejected line items
    #   self.purchase_request.purchase_request_items.non_rejected.each do |item|
    #     params[:document] = item
    #     params[:aasm_event] = 'approve'

    #     op = WorkflowManager::Base.(user, params)
    #   end if self.purchase_request.purchase_request_items.present?
    # else
    #   add_message :error, op.messages[:error]
    #   return
    # end

    # self.workflow_output = op.workflow_output

    begin
      ActiveRecord::Base.transaction do
        params[:document] = self.purchase_request
        params[:aasm_event] = 'approve'
        op = WorkflowManager::Base.(user, params)
        if op.success?
          # Mark rejected line items
          rejected = purchase_request.reject_purchase_request_items(params) if params[:rejected_purchase_request_items].present?
          # Break if rejection fails
          raise if params[:rejected_purchase_request_items].present? && !rejected
          # Approve the line items too
          unless purchase_request&.status&.name&.to_sym&.present? && purchase_request.purchase_request_items.non_rejected.update_all(status_id: PurchaseRequestItemStatus.id_for(purchase_request&.status&.name&.to_sym))
            raise
          end
          # self.purchase_request.purchase_request_items.each do |item|
          #   params[:document] = item
          #   params[:aasm_event] = 'submit'
          #   item_op = WorkflowManager::Base.(user, params)
          # end if self.purchase_request.purchase_request_items.present?
          self.workflow_output = op.workflow_output
        else
          raise
        end
      end
    rescue
      add_message :error, 'Unable to proceed'
    end
  end

  def post_process
    add_message :success, "Purchase request approved"
  end
end