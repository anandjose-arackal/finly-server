class Vendors::Submit < Vendors::Base

  def init
    id = params[:vendor_id] || params[:yes_bank_vendor] || params[:id] 
    self.vendor = Vendors::Show.(user, params).vendors.with_id(id).first rescue nil
  end

  def validate
    unless self.vendor.present?
      add_message :error, "Vendor not found"
    end
  end

  def process
    params[:document] = self.vendor
    params[:aasm_event] = 'submit'

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