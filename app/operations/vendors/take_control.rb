class Vendors::TakeControl < Vendors::Base

  def process
    params[:document] = self.vendor
    params[:aasm_event] = 'take_control'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "You've taken control"
  end
end