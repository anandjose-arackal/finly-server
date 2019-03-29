class Vendors::Retract < Vendors::Base

  def process
    params[:document] = self.vendor
    params[:aasm_event] = 'retract'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "Submitted vendor for approval"
  end
end