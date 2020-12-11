class Procurements::PurchaseRequests::Reject < Procurements::PurchaseRequests::Base

  attr_accessor :reject_note

  def init
    super
    self.reject_note = params[:reject_note]
  end

  def validate
    super

    if params[:reject_to_user].present? && params[:reject_to_level].present?
      reject_to_details = self.purchase_request.reject_to_users # {dlrm_level_id => reviewer, dlrm_level_id => reviewer, ...}
      
      # if rejection possible to requested level and the requested level has the same user details as sent by FE
      if reject_to_details[params[:reject_to_level].to_i].blank? && (reject_to_details[params[:reject_to_level].to_i].try(:id) != params[:reject_to_user])
        add_message :error, "User details not found for this level"
      end
    end
  end

  def process
    # Transactions are tied to one database connection. Hence process only required operations
    begin
      self.purchase_request.paper_trail_event = "Reject"
      ActiveRecord::Base.transaction(requires_new: true) do
        params[:document] = self.purchase_request
        params[:aasm_event] = 'reject'

        op = WorkflowManager::Base.(user, params)
        unless op.success?
          add_message :error, op.messages[:error]
          raise ActiveRecord::Rollback
        end

        self.purchase_request.update(reject_note: reject_note)
        self.workflow_output = op.workflow_output

        if params[:reject_to_user].blank? && params[:reject_to_level].blank?
          raise ActiveRecord::Rollback unless reject_all_line_items
        end
      end
    rescue
      add_message :error, 'Unable to reject'
    end
  end

  def post_process
    unless has_errors?
      Event::EPurchaseRequest::Reject.(user, purchase_request: purchase_request, workflow_output: workflow_output)
      reject_all_line_items
      add_message :success, "You've rejected reviewal of purchase request"
    end
  end

  private
  def reject_all_line_items
    return if params[:reject_to_user].present? && params[:reject_to_level].present?
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