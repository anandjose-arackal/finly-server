class Procurements::PurchaseRequests::CreateAndSubmit < Procurements::PurchaseRequests::Base

  class Procurements::PurchaseRequests::CreateAndSubmit::SubmitPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end
  end

  def init
    # Create Purchase Request
    op_create = Procurements::PurchaseRequests::Create.(user, params)

    if op_create.success?
      self.purchase_request = op_create.purchase_request
    else
      add_message :error, op_create.messages[:error]
    end
  end

  def process
    if self.purchase_request.policy_id.present?
      params[:document] = self.purchase_request
      params[:aasm_event] = 'submit'

      op = WorkflowManager::Base.(user, params)
      unless op.success?
        add_message :error, op.messages[:error]
        return
      end

      self.workflow_output = op.workflow_output
    else
      self.purchase_request.update(status_id: PurchaseRequestStatus.id_for(:auto_approved))
    end
  end

  def post_process
    if purchase_request.status_id == PurchaseRequestStatus.id_for(:auto_approved)
      add_message :success, "Purchase Request Added and Approved"
    else
      add_message :success, "Purchase Request Submitted for Approval"
    end
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::CreateAndSubmit::SubmitPresenter.new(user, params, messages)
  end
end