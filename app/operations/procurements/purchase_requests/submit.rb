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
    ActiveRecord::Base.transaction(requires_new: true) do
      begin
        ActiveRecord::Base.transaction(requires_new: true) do
          params[:document] = self.purchase_request
          params[:aasm_event] = 'submit'
          op = WorkflowManager::Base.(user, params)
          raise unless op.success?
          raise if purchase_request_status.blank?

          # Submit the line items too
          # if purchase_request.purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(purchase_request&.status&.name&.to_sym), rejected: false)
          submit_line_items
          self.workflow_output = op.workflow_output
        end
      rescue StandardError
        add_message :error, 'Unable to proceed'
      end

      return if has_errors?

      check_budget
    end
  end

  def submit_line_items
    purchase_request.items.each do |item|
      item.status_id = PurchaseRequestItemStatus.id_for(purchase_request_status&.to_sym)
      item.rejected = false
      item.trails.create(action_user: user, action_id: TrailAction.id_for(trail_action)) if item.save
    end
  end

  def check_budget
    budget_validation_op = budget_limit_validation(purchase_request)
    if budget_validation_op.present? && budget_validation_op.failure? && budget_validation_op.messages[:errors].present?
      add_message :error, budget_validation_op.messages[:errors]
      raise ActiveRecord::Rollback
    end
  end

  def purchase_request_status
    @purchase_request_status ||= purchase_request&.status&.name
  end

  def trail_action
    if purchase_request_status == 'auto_approved'
      'auto_approve'
    elsif purchase_request_status == 'awaiting_approval'
      'submit'
    end
  end

  def post_process
    auto_approved = purchase_request.purchase_request_status_id == PurchaseRequestStatus.id_for(:auto_approved)
    email_approval_needed = PurchaseRequestToggle.new(user).enabled? && !auto_approved
    create_email_approval_for_purachse_request(purchase_request) if email_approval_needed

    Event::EPurchaseRequest::Submit.(user, purchase_request: purchase_request,
                                           workflow_output: workflow_output,
                                           email_approval_needed: email_approval_needed)

    message = auto_approved ? 'Purchase Request Auto Approved' : 'Purchase Request Submitted for Approval'
    add_message :success, message
  end

  def create_email_approval_for_purachse_request(purchase_request)
    EmailApproval.create_for_purachse_request(purchase_request)
  end

  def success
    params[:purchase_request] = self.purchase_request
    Procurements::PurchaseRequests::Submit::SubmitPresenter.new(user, params, messages)
  end
end
