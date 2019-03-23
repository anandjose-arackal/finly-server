# Vendor Submit will first create the vendor & Then submit it

class Vendors::Submit < Vendors::Base

  class Vendors::Submit::SubmitPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendor

    def init
      self.vendor = params[:vendor]
    end
  end

  def init
    # Create Vendor
    op_create = Vendors::Create.(user, params)

    if op_create.success?
      self.vendor = op_create.vendor
    else
      add_message :error, op_create.messages[:error]
    end
    # id = params[:vendor_id] || params[:yes_bank_vendor] || params[:id] 
    # self.vendor = Vendors::Show.(user, params).vendors.with_id(id).first rescue nil
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

  def success
    params[:vendor] = self.vendor
    Vendors::Submit::SubmitPresenter.new(user, params, messages)
  end
end