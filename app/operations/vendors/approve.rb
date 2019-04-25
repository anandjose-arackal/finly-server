class Vendors::Approve < Vendors::Base
  def process
    params[:document] = self.vendor
    params[:aasm_event] = 'approve'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "Approved Vendor"
    Event::EVendors::Approve.(user, document: self.vendor)
  end
end