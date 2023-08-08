class Email::Pr_Approval_Service
  attr_reader :user, :purchase_request, :mail_from, :logger, :email_body

  def initialize(user, purchase_request, mail_from, email_body, error_logger = nil)
    @user = user
    @purchase_request = purchase_request
    @mail_from = mail_from
    @logger = error_logger || set_error_logger
    @email_body = email_body
  end

  def process
    return if purchase_request_not_awaiting_approval? && log_purchase_request_not_awaiting_approval
    return if purchase_request_disabled? && log_purchase_request_disabled

    aprove_or_reject
  end

  def purchase_request_not_awaiting_approval?
    !purchase_request.awaiting_approval?
  end

  def log_purchase_request_not_awaiting_approval
    logger.error("PR #{purchase_request.id} failed because it is in
            #{purchase_request.status.name} status, not in AWAITING APPROVAL status")

    true
  end

  def purchase_request_disabled?
    !PurchaseRequestToggle.new(@user).enabled?
  end

  def log_purchase_request_disabled?
    logger.error("PR #{purchase_request.id} failed because PurchaseRequest toggle is not enabled for user #{user.email}")
    delete_email_approvals

    true
  end

  def set_error_logger
    Logger.new(Constants::EMAIL_APPROVAL_ERROR_PATH)
  end

  def delete_email_approvals
    EmailApproval.delete_email_approval(purchase_request.id)
  end

  def aprove_or_reject
    if email_body.downcase.include?('approve') && can_approve?
      approve
    elsif email_body.downcase.include?('reject') && can_reject?
      reject
    else
      logger.info "PR #{purchase_request.id}, From #{mail_from}, Mail Content doesn't contain Approve or Reject"
    end
  end

  def approve
    @result = Event::EPurchaseRequest::Approve.(user, purchase_request: purchase_request, workflow_output: apporve_work_flow)

    if @result.success?
      if purchase_request.approved?
        after_approval
      elsif purchase_request.awaiting_approval?
        EmailApproval.create_for_purachse_request(purchase_request)
      end
    else
      logger.error("purchase_request #{purchase_request.id} failed to approve by #{mail_from} because #{@result.inspect}")
    end
  end

  def after_approval
    EmailApproval.delete_email_approval(purchase_request.id)
    approve_purchase_request_items
  end

  def apporve_work_flow
    WorkflowManager::Base.(user, { document: purchase_request, aasm_event: 'approve' }).workflow_output
  end

  def reject_work_flow
    WorkflowManager::Base.(user, { document: purchase_request, aasm_event: 'reject' }).workflow_output
  end

  def approve_purchase_request_items
    update_purchase_request_items_status(PurchaseRequestItemStatus.id_for(:approved))
  end

  def reject_purchase_request_items
    update_purchase_request_items_status(PurchaseRequestItemStatus.id_for(:rejected))
  end

  def update_purchase_request_items_status(status_id)
    purchase_request.purchase_request_items.update_all(status_id: status_id)
  end

  def reject
    note = "purchase_request has been rejected via email by #{mail_from} on #{Time.now.strftime('%Y-%d-%m %H:%M:%S %Z')}"
    @result = Event::EPurchaseRequest::Reject.(@user, purchase_request: purchase_request, workflow_output: reject_work_flow, note: note)

    if @result.success?
      EmailApproval.delete_email_approval(purchase_request.id)
      reject_purchase_request_items
    else
      logger.error("purchase_request #{purchase_request.id} failed to reject by #{mail_from} because #{@result.inspect}")
    end
  end

  def can_approve?
    purchase_request.awaiting_approval? && reviewer?
  end

  def can_reject?
    purchase_request.awaiting_approval? && reviewer?
  end

  def reviewer?
    purchase_request.get_reviewers(nil, provider_name).include?(@user)
  end

  def provider_name
    purchase_request.get_default_provider
  end
end
