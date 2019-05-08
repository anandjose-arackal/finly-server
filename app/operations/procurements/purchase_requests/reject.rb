class Procurements::PurchaseRequests::Reject < Procurements::PurchaseRequests::Base

  def validate
    super
    if params[:reject_note].blank?
      add_message :error, 'Please add reject note'
    end
  end

  def process
    # Transactions are tied to one database connection. Hence process only required operations
    begin
      ActiveRecord::Base.transaction do
        params[:document] = self.purchase_request
        params[:aasm_event] = 'reject'

        op = WorkflowManager::Base.(user, params)
        unless op.success?
          add_message :error, op.messages[:error]
          raise ActiveRecord::Rollback
        end
        self.purchase_request.update(reject_note: params[:reject_note])
        self.workflow_output = op.workflow_output

        raise ActiveRecord::Rollback unless reject_all_line_items
      end
    rescue
      add_message :error, 'Unable to reject'
    end
  end

  def post_process
    reject_all_line_items
    add_message :success, "You've rejected reviewal of purchase request"
  end

  private
  def reject_all_line_items
    self.purchase_request.purchase_request_items.non_rejected.each do |line_item|
      line_item.rejected = true
      line_item.status_id = PurchaseRequestItemStatus.id_for(:rejected)
      unless line_item.save #&& PurchaseRequest.create_status_change_trail(line_item, user, action_id=TrailAction.id_for(:reject))
        return false
      end
    end
    true
  end
end