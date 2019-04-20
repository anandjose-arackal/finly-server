class Vendors::Reactivate < Vendors::Base

  class Vendors::Reactivate::ReactivatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendor

    def init
      self.vendor = params[:vendor]
    end
  end

  def init
    # id = params[:id] || params[:vendor_id] || params[:yes_bank_vendor_id]
    self.vendor = Vendors::Show.(user, params).vendor rescue nil
  end

  def process
    params[:document] = self.vendor
    params[:aasm_event] = 'reactivate'

    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    add_message :success, "Vendor Successfully Reactivated"
  end

  def success
    params[:vendor] = self.vendor
    Vendors::Reactivate::ReactivatePresenter.new(user, params, messages)
  end
end