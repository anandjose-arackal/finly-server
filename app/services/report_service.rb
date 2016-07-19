class ReportService < BaseService
  attr_accessor :report, :user, :user_team_service, :report_detail_service

  def initialize(params={})
    super()
    self.report = params[:report]
    self.user = params[:user]
    self.user_team_service = UserTeamService.new(self.user)
    self.report_detail_service = ReportDetailService.new(self.report)
  end

  # Todo assigning forwarding_to_user for report upon create, submit, approve etc

  def self.list_reports

  end

  def user_role_for_report
    return nil unless validate controlling_user: true
    user = report.controlling_for_user
    user = report.controlling_user if user.blank?
    uts = UserTeamService.new(user)
    if user.id == report.user.id
      return UserRole.employee_id
    end
    if user.manager? and uts.manager_for?(report)
      return UserRole.manager_id
    elsif user.finance_manager? and uts.finance_manager_for?(report)
      return UserRole.finance_manager_id
    end
  end

  def next_reviewer_for_report
    return false unless validate controlling_user: true
    user = report.controlling_for_user
    user = report.controlling_user if user.blank?
    uts = UserTeamService.new(user)
    if report.user.id == user.id
      manager = uts.manager(report: report)
      if manager.nil?
        return uts.finance_manager(report: report)
      else
        return manager
      end
    end
    if user.manager? and uts.manager_for?(report)
      manager = uts.approves_to(report: report)
      if manager.nil?
        return UserTeamService.new(report.user).finance_manager(report: report)
      else
        return manager
      end
    end
    if user.finance_manager? and uts.finance_manager_for?(report)
      uts.approves_finance_to report: report
    end
  end

  def create(params={})
    return false unless validate require_user: true
    report = user.reports.build status: ReportStatus.open, controlling_user: user, name: params[:name]
    if report.save
      self.report = report
      report_track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.create_id, report_status_id: ReportStatus.open_id
      report_track.save
      if params[:expenses].present?
        add_expense params[:expenses]
      end
      return report
    end
    errors << report.errors.full_messages
    false
  end

  def submit(params={})
    return false unless validate controlling_user: true
    unless report.user.id == user.id
      errors << 'Only report owners can submit reports'
      return false
    end
    unless report.status.open? or report.status.retracted?
      errors << 'Cannot submit this report'
      return false
    end
    unless report.expenses.present?
      errors << 'Cannot submit a blank report'
      return false
    end
    manager = next_reviewer_for_report
    # If no manager assigned, auto approve the report
    if manager.blank?
      return approve(auto_approve: true)
    end
    memo = params[:memo]
    submitted_at = report.submitted_at
    submitted_at = DateTime.now if submitted_at.blank?
    if report.update_attributes report_status_id: ReportStatus.processing_id, controlling_user_id: manager.id, controlling_for_user_id: nil, memo: memo, submitted_at: submitted_at
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.submit_id, report_status_id: ReportStatus.processing_id, memo: memo
      track.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_submit_id
      comment.save
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.submitted_id)
      end
      return true

    end
    errors << report.errors.full_messages
    false
  end

  def retract
    return false unless validate owner: true
    unless report.user.id == user.id
      errors << 'Only report owners can retract report'
      return false
    end
    unless report.processing?
      errors << 'Cannot retract report'
      return false
    end
    if report.update_attributes report_status_id: ReportStatus.retracted_id, controlling_user_id: user.id, controlling_for_user_id: nil, memo: nil
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.retract_id, report_status_id: ReportStatus.retracted_id
      track.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_retract_id
      comment.save
      report.expenses.each do |expense|
        expense.update_attribute(:expense_status_id, ExpenseStatus.unsubmitted_id)
      end
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def approve(params={})
    return false unless validate controlling_user: true
    auto_approve = params[:auto_approve]
    unless report.controlling_user.id == user.id
      errors << 'User cannot approve this report'
      return false
    end
    unless report.status.processing? or auto_approve
      errors << 'Cannot review report'
      return false
    end
    manager = next_reviewer_for_report
    status = ReportStatus.processing_id
    if auto_approve or manager.blank?
      settlement = SettlementService.new(report.user)
      status = ReportStatus.approved_id
      unless settlement.require_reimbursement?(report)
        status = ReportStatus.closed_id
      end
    end
    manager_id = nil
    manager_id = manager.id if manager.present?
    user_role = user_role_for_report
    # # If reimbursable expenses are present
    # if manager_id.blank? and report.is_reimbursable? and UserTeamService.new(user).finance_manager_for?(report)
    #   manager_id = user.id
    # end
    if report.update_attributes report_status_id: status, controlling_user_id: manager_id, controlling_for_user_id: nil, memo: nil
      if auto_approve
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_auto_approve_id
        track = report.tracks.build action_user: nil, report_tracking_action_id: ReportTrackingAction.auto_approve_id, report_status_id: status
      else
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_approve_id
        track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.approve_id, report_status_id: status,
                                    user_report_role_id: user_role
      end
      track.save
      comment.save
      # Recompute settlement
      unless report.processing?
        SettlementService.new.report_approved report
      end
      # Add comments stating report has been closed as no reimbursements required
      if report.closed?
        comment = report.comments.build user: nil, report_comment_action_id: ReportCommentAction.report_closed_id
        track = report.tracks.build action_user: nil, report_tracking_action_id: ReportTrackingAction.closed_id, report_status_id: ReportStatus.closed_id
        comment.save
        track.save
      end
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def reject(to_user=nil, memo=nil)
    return false unless validate controlling_user: true
    unless report.controlling_user.id == user.id
      errors << 'User cannot reject this report'
      return false
    end
    unless report.processing?
      errors << 'Cannot reject this report after the report is approved'
      return false
    end
    if to_user.blank?
      # If no reject to user is provided, reject to report owner
      to_user = report.user
    else
      # Check if reject to user is a part of the chain
      rejectable_users = rejectable_to_users
      unless rejectable_users.present? and rejectable_users.with_id(to_user.id).present?
        errors << 'Reject to user not found'
        return false
      end
    end
    status = ReportStatus.rejected_id
    if to_user.id != report.user.id
      status = ReportStatus.processing_id
    end
    if report.update_attributes report_status_id: status, controlling_user_id: to_user.id, controlling_for_user_id: nil, memo: memo
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reject_id, report_status_id: status, memo: memo
      track.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reject_id, rejected_to_id: to_user.id, content: memo,
                                      user_report_role_id: UserRole.employee_id
      comment.save
      # Reset expenses status to unsubmitted if report is rejected
      if status == ReportStatus.rejected_id
        report.expenses.each do |expense|
          expense.update_attribute :expense_status_id, ExpenseStatus.unsubmitted_id
        end
      end
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def unapprove
    return false unless validate require_user: true, require_report: true
    if report.user.id == user.id
      errors << 'User cannot unapprove this report'
      return false
    end
    unless report.can_unapprove?
      errors << 'Cannot unapprove this report'
      return false
    end
    associated_users = report.associated_users(report.controlling_user)
    unless associated_users.present? and associated_users.with_id(user.id).present?
      errors << 'User has not yet reviewed the report to unapprove it'
      return false
    end
    prev_status = report.status
    if report.update_attributes controlling_user_id: user.id, controlling_for_user_id: nil, memo: nil, report_status_id: ReportStatus.processing_id
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.unapprove_id, report_status_id: ReportStatus.processing_id
      track.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_unapprove_id
      comment.save
      # Recalculate settlement when report is unapproved from an approved/closed state
      if prev_status.approved? or prev_status.closed?
        SettlementService.new.report_unapproved report
      end
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def mark_as_reimbursed(payment)
    return false unless validate require_user: true, require_report: true
    unless payment.present?
      errors << 'Require payment details to mark the report as reimbursed'
      return false
    end
    unless report.reimbursement_pending?
      errors << 'Report cannot be reimbursed'
      return false
    end
    # Mark the controlling user as the reports owner so he can mark the report as payment_received
    if report.update(reimbursement: payment, report_status_id: ReportStatus.reimbursed_id, controlling_user: report.user, controlling_for_user: nil)
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reimbursed_id,
                                  report_status_id: ReportStatus.reimbursed_id, payment: payment
      track.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reimbursed_id, payment: payment
      comment.save
      return true
    end
    errors = errors + report.errors.full_messages
    false
  end

  # def reimburse(params={})
  #   return false unless validate require_report: true, require_user: true
  #   unless report.controlling_user.present? and report.controlling_user.id == user.id and user.finance_manager?
  #     errors << 'User cannot perform this action on the report'
  #     return false
  #   end
  #   unless report.approved?
  #     errors << 'Report cannot be marked as reimbursed currently'
  #     return false
  #   end
  #   unless report.is_reimbursable?
  #     errors << 'Report does not have any reimbursable expense to be marked as reimbursed'
  #     return false
  #   end
  #   if report.update_attributes controlling_user: report.user, controlling_for_user: nil, report_status_id: ReportStatus.reimbursed_id, memo: params[:memo]
  #     track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reimburse_id, report_status_id: ReportStatus.reimbursed_id
  #     track.save
  #     comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reimburse_id
  #     comment.save
  #     return true
  #   end
  #   errors << report.errors.full_messages
  #   false
  # end

  def reimbursement_confirm
    return false unless validate owner: true
    unless report.reimbursed?
      errors << 'Report cannot be confirm reimbursement as the report is not marked as reimbursed'
      return false
    end
    if report.update_attributes controlling_user: nil, controlling_for_user: nil, status: ReportStatus.reimbursement_confirmed_id, memo: nil
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.reimbursement_confirmed_id, report_status_id: ReportStatus.reimbursement_received_id
      track.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_reimbursement_confirmed_id
      comment.save
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def delete_report
    return false unless validate owner: true
    unless report.open? or report.retracted?
      errors << 'Report cannot be deleted unless the report is retracted'
      return false
    end
    if report.destroy
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def archive_report
    return false unless validate owner: true
    unless report.can_archive?
      errors << 'Report is still not completely processed to archive it'
      return false
    end
    if report.update_attributes archived: true
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def take_control(memo=nil)
    return false unless validate require_user: true, require_report: true
    unless user.admin? or (report.policy.present? and user.policy_admin? report.policy)
      errors << 'User cannot take control of this report'
      return false
    end
    unless report.can_take_control?
      errors << 'User cannot take control of this report'
      return false
    end
    if report.update_attributes controlling_user: user, controlling_for_user: report.controlling_user, memo: memo
      track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.take_control_id,
                                  report_status_id: report.status_id, memo: memo
      track.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_take_control_id, content: memo
      comment.save
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def share_with(users)

  end

  def rejectable_to_users
    return false unless validate require_report: true
    return nil unless report.processing?
    report.associated_users(user)
  end

  def expense_created_in_report(expense)
    return false unless validate require_report: true, require_user: true
    comment = report.comments.build report: report, user: user, report_comment_action: ReportCommentAction.expense_add_id, expense: expense
    if comment.save
      return true
    end
    errors << comment.errors.full_messages
    false
  end

  # Callback to create comments in reports when expense is updated
  def expense_updated_in_report(expense)

  end

  def add_expense(expense_ids)
    return false unless validate controlling_user: true
    unless report.user.id == user.id
      errors << 'Only report owners can add expenses to report'
      return false
    end
    if expense_ids.blank?
      errors << 'Expense not found'
      return false
    end
    expenses = user.expenses.unreported.with_id(expense_ids)
    if expenses.blank?
      errors << 'Expense not found'
      return false
    end
    unless report.open? or report.retracted?
      errors << 'Cannot add expenses to report unless report is in open or retracted state'
      return false
    end
    retracted = report.retracted?
    expenses.each do |expense|
      if expense.update_attributes(report_id: report.id, expense_status_id: ExpenseStatus.unsubmitted_id, manager_memo: nil, rejecting_manager: nil)
        if retracted
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.expense_add_id, expense_id: expense.id
          comment.save
        end
      end
    end
    report.reload
  end

  def remove_expense(expense_ids)
    return false unless validate controlling_user: true
    unless report.user.id == user.id
      errors << 'Only report owners can remove expenses from report'
      return false
    end
    if expense_ids.blank?
      errors << 'Expense not found'
      return false
    end
    expenses = report.expenses.with_id(expense_ids)
    if expenses.blank?
      errors << 'Expense not found'
      return false
    end
    unless report.open? or report.retracted?
      errors << 'Cannot remove expenses from report unless report is in open or retracted state'
      return false
    end
    retracted = report.retracted?
    expenses.each do |expense|
      if expense.update_attributes report_id: nil, expense_status_id: ExpenseStatus.unreported_id
        if retracted
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.expense_remove_id, expense_id: expense.id
          comment.save
        end
      end
    end
    report.reload
  end

  def reject_expense(expense_ids, params={})
    return false unless validate controlling_user: true
    unless report.controlling_user_id.present? and report.controlling_user.id == user.id
      errors << 'You do not control the report to perform the following action'
      return false
    end
    if expense_ids.blank?
      errors << 'Expense not found'
      return false
    end
    expenses = report.expenses.with_id(expense_ids)
    if expenses.blank?
      errors << 'Expense not found'
      return false
    end
    unless report.processing?
      errors << 'Cannot reject expenses from report unless report is in processing state'
      return false
    end
    expenses.each do |expense|
      if expense.update_attributes(report_id: nil, expense_status_id: ExpenseStatus.rejected_id,
                                   manager_memo: params[:memo], rejecting_manager: user)
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.expense_reject_id, expense_id: expense.id, content: params[:memo]
        comment.save
      end
    end
    report.reload
  end

  def rename_report(name)
    return false unless validate controlling_user: true
    old_name = report.name
    report.name = name
    if report.save
      comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_update_id, updated_field: 'name', updated_from: old_name, updated_to: report.name
      comment.save
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def load_receipt_params(params)
    params[:receipt].slice(:image)
  end

  # accepts receipt and expense
  def add_receipt_to_report(params = {})
    return false unless validate owner: true
    unless report.open? or report.retracted?
      errors << 'Cannot attach receipt unless report is open or retracted'
      return false
    end
    unless params.present?
      errors << 'Params is empty'
      return false
    end
    receipt_params = load_receipt_params params
    # create the receipt associated with the report
    attach = report.receipts.build(receipt_params)
    # associating the current user with the receipt
    attach.user = user
    if attach.save
      return true
    end
    errors << attach.errors.full_messages
    false
  end

  def attach_receipt_to_report(receipt_id)
    return false unless validate owner: true
    unless report.open? or report.retracted?
      errors << 'Cannot attach receipt unless report is open or retracted'
      return false
    end
    unless receipt_id.present?
      errors << 'Receipt not found'
      return false
    end
    receipt = user.receipts.find_by(id: receipt_id)
    if receipt.parent
      errors << 'Receipt is already attached to another expense.'
      return false
    end
    receipt.parent = report
    if receipt.save
      return true
    end
    errors << receipt.errors.full_messages
    false
  end

  # will just remove the association between expense and receipt
  def detach_receipt_from_expense(receipt_id)
    return false unless validate owner: true
    unless report.open? or report.retracted?
      errors << 'Cannot detach receipt unless report is open or retracted'
      return false
    end
    unless receipt_id.present?
      errors << 'Receipt not found'
      return false
    end
    receipt = user.receipts.find_by(id: receipt_id)
    if receipt.nil? || receipt.parent_id != expense_id
      errors << 'Receipt does not belong to this report.'
      return false
    end
    receipt.parent_id = receipt.parent_type = nil
    if receipt.save
      return true
    end
    errors << receipt.errors.full_messages
    false
  end

  def export(format)

  end

  def comment(content)
    return false unless validate require_report: true, require_user: true
    return true if content.blank?
    comment = report.comments.build(report_comment_action_id: ReportCommentAction.report_comment_id, user_id: user.id, content: content)
    if comment.save
      return true
    end
    self.errors = comment.errors.full_messages
    false
  end

  def assign_policy(policy_id)
    return false unless validate owner: true
    unless report.open? or report.retracted?
      errors << 'Cannot assign policy unless report is retracted'
      return false
    end
    if report.policy_id == policy_id
      return true
    end
    if report.update_attribute(:policy_id, policy_id, submitted_at: nil)
      return true
    end
    errors << report.errors.full_messages
    false
  end

  private
  # Used for internal validates of each of the functions in report_service object.
  # require_user: check if report_service has been initialized with user.
  # require_report: checks if report_service has been initialized with report.
  # controlling_user: checks if report_service has been initialized with the controlling user of the report
  # owner: checks if report_service is initialized
  def validate(params={})
    errors.clear
    require_report = (params[:require_report] or params[:controlling_user] or params[:owner])
    if self.report.blank? and require_report
      errors << 'Report not found'
    end
    require_user = (params[:require_user] or params[:controlling_user] or params[:owner])
    if self.user.blank? and require_user
      errors << 'User not found'
    end
    if errors.blank?
      if params[:controlling_user] and (report.controlling_user.blank? or self.user.id != report.controlling_user.id)
        errors << 'User cannot perform this action on the report'
      end
      if params[:owner] and report.user.id != user.id
        errors << 'User is not the report owner'
      end
    end
    errors.blank?
  end

end