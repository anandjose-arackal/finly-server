class Email::PoApprovalService
  attr_reader :user, :purchase_order, :mail_from, :logger, :email_body

  def initialize(user, purchase_order, mail_from, email_body, error_logger = nil)
    @user = user
    @purchase_order = purchase_order
    @mail_from = mail_from
    @logger = error_logger || set_error_logger
    @email_body = email_body
  end

  def process
    return if purchase_order_not_processing? && log_purchase_order_not_processing
    return if purchase_order_disabled? && log_purchase_order_disabled

    aprove_or_reject
  end

  def purchase_order_not_processing?
    !purchase_order.processing?
  end

  def log_purchase_order_not_processing
    logger.error("PR #{purchase_order.id} failed because it is in
              #{purchase_order.status.name} status, not in PROCESSING status")

    true
  end

  def purchase_order_disabled?
    !PurchaseRequestToggle.new(@user).enabled?
  end

  def log_purchase_order_disabled?
    logger.error("PR #{purchase_order.id} failed because PurchaseOrder toggle is not enabled for user #{user.email}")
    delete_email_approvals

    true
  end

  def set_error_logger
    Logger.new(Constants::EMAIL_APPROVAL_ERROR_PATH)
  end

  def delete_email_approvals
    EmailApproval.delete_email_approval(purchase_order.id)
  end

  def aprove_or_reject
    if email_body.downcase.include?('approve') && can_approve?
      approve
    elsif email_body.downcase.include?('reject') && can_reject?
      reject
    else
      logger.info "PR #{purchase_order.id}, From #{mail_from}, Mail Content doesn't contain Approve or Reject"
    end
  end

  def approve
    @result = Event::EPurchaseOrder::Approve.(user, purchase_order: purchase_order, workflow_output: apporve_work_flow)
    if @result.success?
      if purchase_order.approved?
        after_approval
      elsif purchase_order.processing?
        EmailApproval.create_for(purchase_order)
      end
    else
      logger.error("purchase_order #{purchase_order.id} failed to approve by #{mail_from} because #{@result.inspect}")
    end
  end

  def after_approval
    EmailApproval.delete_email_approval(purchase_order.id)
    approve_purchase_request_items
  end

  def approve_purchase_request_items
    purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(:po_approved))
  end

  def reject_purchase_request_items
    purchase_request_items.update_all(status_id: PurchaseRequestItemStatus.id_for(:po_approved))
  end

  def purchase_request_items
    @purchase_request_items ||= purchase_order.purchase_request_items
  end

  def apporve_work_flow
    WorkflowManager::Base.(user, { document: purchase_order, aasm_event: 'approve' }).workflow_output
  end

  def reject_work_flow
    WorkflowManager::Base.(user, { document: purchase_order, aasm_event: 'reject' }).workflow_output
  end

  def reject
    note = "purchase_order has been rejected via email by #{mail_from} on #{Time.now.strftime('%Y-%d-%m %H:%M:%S %Z')}"
    @result = Event::EPurchaseOrder::Reject.(@user, purchase_order: purchase_order, workflow_output: reject_work_flow, note: note)

    if @result.success?
      EmailApproval.delete_email_approval(purchase_order.id)
      reject_purchase_request_items
    else
      logger.error("purchase_order #{purchase_order.id} failed to reject by #{mail_from} because #{@result.inspect}")
    end
  end

  def can_approve?
    purchase_order.processing? && reviewer?
  end

  def can_reject?
    purchase_order.processing? && reviewer?
  end

  def reviewer?
    purchase_order.get_reviewers(nil, provider_name).include?(@user)
  end

  def provider_name
    purchase_order.get_default_provider
  end
end
