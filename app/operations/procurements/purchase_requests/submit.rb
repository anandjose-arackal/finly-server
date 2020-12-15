class Procurements::PurchaseRequests::Submit < Procurements::PurchaseRequests::Base

  class Procurements::PurchaseRequests::Submit::SubmitPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_request

    def init
      self.purchase_request = params[:purchase_request]
    end
  end

  def init
    super

    fetch_budget_contributions(purchase_request)
  end

  def rollback_process_if_error?
    true
  end

  def process
    self.purchase_request.paper_trail_event = "Submit"
    ActiveRecord::Base.transaction(requires_new: true) do
      begin
        ActiveRecord::Base.transaction(requires_new: true) do
          params[:document] = self.purchase_request
          params[:aasm_event] = 'submit'
          op = WorkflowManager::Base.(user, params)
          if op.success?
            # Submit the line items too
            purchase_request_status = purchase_request&.status&.name
            if purchase_request_status.present?
              # if purchase_request.purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(purchase_request&.status&.name&.to_sym), rejected: false)
              if purchase_request_status == 'auto_approved'
                trail_action = 'auto_approve'
              elsif purchase_request_status == 'awaiting_approval'
                trail_action = 'submit'
              end
              purchase_request.purchase_request_items.each do |item|
                item.status_id = PurchaseRequestItemStatus.id_for(purchase_request&.status&.name&.to_sym)
                item.rejected = false
                if item.save
                  trail = item.trails.create(action_user: user, action_id: TrailAction.id_for(trail_action))
                end
              end
            else
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

      return if has_errors?

      # Budget check
      budget_validation_op = budget_limit_validation(purchase_request)
      if budget_validation_op.present? && budget_validation_op.failure? && budget_validation_op.messages[:errors].present?
        add_message :error, budget_validation_op.messages[:errors]
        raise ActiveRecord::Rollback
        return
      end
    end
  end

  def post_process
    Event::EPurchaseRequest::Submit.(user, purchase_request: purchase_request, workflow_output: workflow_output)
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