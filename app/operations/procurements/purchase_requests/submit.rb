class Procurements::PurchaseRequests::Submit < Procurements::PurchaseRequests::Base

  class Procurements::PurchaseRequests::Submit::SubmitPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end
  end

  # def init
  #   id = params[:id] || params[:purchase_request_id]
  #   self.purchase_request = Procurements::PurchaseRequests::Show.(user, params).purchase_request.with_id(id).first rescue nil
  # end

  def process
    params[:document] = self.purchase_request
    params[:aasm_event] = 'submit'
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    if purchase_request.purchase_request_status_id == PurchaseRequestStatus.id_for(:auto_approved)
      add_message :success, "Purchase Request Auto Approved"
    else
      add_message :success, "Purchase Request Submitted for Approval"
    end
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::Submit::SubmitPresenter.new(user, params, messages)
  end
end