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
          # Unapprove the line items too
          # Non rejected items will follow PR status
          unless purchase_request&.status&.name&.to_sym&.present? && purchase_request.purchase_request_items.non_rejected.update_all(status_id: PurchaseRequestItemStatus.id_for(purchase_request&.status&.name&.to_sym))
            raise
          end
          # # Rejected line items by current reviewer will rollback to awaiting_approval state
          # # Rejected line items by previous reviewer will remain rejected
          # status_changed = rollback_rejected_items_status
          # # Rollack changes if anything fails
          # raise if !status_changed
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

  private

  # def rollback_rejected_items_status
  #   purchase_request.purchase_request_items.rejected.each do |item|
  #     if item.trails.order(:created_at).last.action_id == TrailAction.id_for(:reject)
  #       item.rejected = false
  #       item.status_id = PurchaseRequestItemStatus.id_for(:awaiting_approval)
  #     end
  #   end unless purchase_request.purchase_request_items&.rejected.blank?
  # end
end