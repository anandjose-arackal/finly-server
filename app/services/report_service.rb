class ReportService < BaseService
  attr_accessor :report, :user, :user_team_service, :report_detail_service

  def initialize(params={})
    super()
    self.report = params[:report]
    self.user = params[:user]
    self.user_team_service = UserTeamService.new(self.user)
    self.report_detail_service = ReportDetailService.new(self.report)
  end

  def self.list_reports

  end

  def create(params={})
    return false unless validate require_user: true
    report = user.reports.build status: ReportStatus.open, controlling_user: user, name: params[:name]
    if report.save
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
    return false unless validate require_user: true, require_report: true
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
    user_team_service = UserTeamService.new(self.user)
    manager = user_team_service.manager(currency: report_detail_service.currency, amount: report_detail_service.total_amount)
    # If no manager assigned, auto approve the report
    if manager.blank?
      return approve(auto_approve: true)
    end
    memo = params[:memo]
    if report.update_attributes report_status_id: ReportStatus.processing_id, controlling_user_id: manager.id, memo: memo
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
    return false unless validate require_user: true, require_report: true
    unless report.user.id == user.id
      errors << 'Only report owners can retract report'
      return false
    end
    unless report.status.processing? or report.status.approved?
      errors << 'Cannot retract report'
      return false
    end
    if report.update_attributes report_status_id: ReportStatus.retracted_id, controlling_user_id: user.id
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
    return false unless validate require_user: true, require_report: true
    auto_approve = params[:auto_approve]
    unless report.controlling_user.id == user.id
      errors << 'User cannot approve this report'
      return false
    end
    unless report.status.processing? or auto_approve
      errors << 'Cannot review report'
      return false
    end
    user_team_service = UserTeamService.new(self.user)
    manager = user_team_service.approves_to(currency: report_detail_service.currency, amount: report_detail_service.total_amount)
    status = ReportStatus.processing_id
    if auto_approve or manager.blank?
      status = ReportStatus.approved_id
      user_team_service = UserTeamService.new(report.user)
      manager = user_team_service.finance_manager(currency: report_detail_service.currency, amount: report_detail_service.total_amount)
    end
    manager_id = nil
    manager_id = manager.id if manager.present?
    if report.update_attributes report_status_id: status, controlling_user_id: manager_id
      if auto_approve
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_auto_approve_id
        track = report.tracks.build action_user: nil, report_tracking_action_id: ReportTrackingAction.auto_approve_id, report_status_id: status
      else
        comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.report_approve_id
        track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.approve_id, report_status_id: status
      end
      track.save
      comment.save
      return true
    end
    errors << report.errors.full_messages
    false
  end

  def reject(to_user, memo)

  end

  def unapprove

  end

  def reimburse

  end

  def reimburse_confirm

  end

  def close

  end

  def share_with(users)

  end

  def rejectable_to_users
    return false unless validate require_report: true
    report.associated_users(user)
  end

  def add_expense(expense_ids)
    return false unless validate require_user: true, require_report: true
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
    return false unless validate require_user: true, require_report: true
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
    return false unless validate require_user: true, require_report: true
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
    unless report.processing? or report.approved?
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

# Callback to create comments in reports when expense is updated
  def expense_updated(expense)

  end

  def rename_report(name)
    return false unless validate require_report: true
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

  def attach_receipt

  end

  def delete_report

  end

  def archive_report

  end

  def create_new_expense(params)

  end

  def take_control(memo)

  end

  def export(format)

  end

  def comment(content)

  end

  private
  def validate(params={})
    errors.clear
    if self.report.blank? and params[:require_report]
      errors << 'Report not found'
    end
    if self.user.blank? and params[:require_user]
      errors << 'User not found'
    end
    errors.blank?
  end

end