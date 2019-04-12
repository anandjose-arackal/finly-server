class Procurements::PurchaseRequests::Unapprove < Procurements::PurchaseRequests::Base

  def process
    # params[:document] = self.purchase_request
    # params[:aasm_event] = 'unapprove'

    # op = WorkflowManager::Base.(user, params)
    # unless op.success?
    #   add_message :error, op.messages[:error]
    #   return
    # end

    # self.workflow_output = op.workflow_output

    begin
      ActiveRecord::Base.transaction do
        params[:document] = self.purchase_request
        params[:aasm_event] = 'unapprove'
        op = WorkflowManager::Base.(user, params)
        if op.success?
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
    add_message :success, "Purchase request unapproved"
  end
end