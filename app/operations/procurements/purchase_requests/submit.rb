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
    begin
      ActiveRecord::Base.transaction do
        params[:document] = self.purchase_request
        params[:aasm_event] = 'submit'
        op = WorkflowManager::Base.(user, params)
        if op.success?
          # Submit the line items too
          unless purchase_request&.status&.name&.to_sym&.present? && purchase_request.purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(purchase_request&.status&.name&.to_sym), rejected: false)
            raise
          end
        else
          raise
        end
        self.workflow_output = op.workflow_output
      end
    rescue
      add_message :error, 'Unable to proceed'
    end
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