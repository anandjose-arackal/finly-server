class Vendors::Reject < Vendors::Base

  def validate
    super

    if params[:reject_to_user].present? && params[:reject_to_level].present?
      reject_to_details = self.vendor.reject_to_users # {dlrm_level_id => reviewer, dlrm_level_id => reviewer, ...}
      
      # if rejection possible to requested level and the requested level has the same user details as sent by FE
      if reject_to_details[params[:reject_to_level].to_i].blank? && (reject_to_details[params[:reject_to_level].to_i].try(:id) != params[:reject_to_user])
        add_message :error, "User details not found for this level"
      end
    end
  end

  def process
    self.vendor.paper_trail_event = "Reject"
    params[:document] = self.vendor
    params[:aasm_event] = 'reject'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.vendor.update(reject_note: params[:note])

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "You've rejected reviewal of vendor"
    Event::EVendors::Reject.(user, document: self.vendor)
  end
end