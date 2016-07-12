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
    report = user.reports.build status: ReportStatus.open, controlling_user: user
    report_track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.create_id, report_status_id: ReportStatus.open_id
    if report.save
      if report_track.save
        return report
      end
      report.destroy
      errors << report_track.errors.full_messages
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
      if track.save
        return true
      end
      errors << track.errors.full_messages
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
      if track.save
        return true
      end
      errors << track.errors.full_messages
    end
    errors << report.errors.full_messages
    false
  end

  def approve(params)
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
    if report.update_attributes report_status_id: status, controlling_user_id: manager.id
      if auto_approve
        track = report.tracks.build action_user: nil, report_tracking_action_id: ReportTrackingAction.auto_approve_id, report_status_id: status
      else
        track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.approve_id, report_status_id: status
      end
      if track.save
        return true
      end
      errors << track.errors.full_messages
    end
    errors << report.errors.full_messages
    false
  end

  def reject_to_users

  end

  def reject(to_user, memo)
    errors.clear

  end

  def unapprove

  end

  def reimburse

  end

  def reimburse_confirm

  end

  def close

  end

  def add_expense(expense_ids)
    return false unless validate require_user: true, require_report: true
    if expense_ids.blank?
      errors << 'Expense not found'
      return false
    end
    expenses = user.expenses.unreported.where(id: expense_ids)
    if expenses.blank?
      errors << 'Expense not found'
      return false
    end
    expenses.each { |expense| expense.update_attribute(:report_id, report.id) }
    report.reload
    # if expenses.is_a?(Expense)
    #   if expenses.user.id != self.user.id
    #     errors << 'User does not have permission to add this expense to the report'
    #     return false
    #   end
    #   expenses.update_attribute(:report, report)
    # else
    #   if expenses.where.not(user_id: user.id).present?
    #     errors << 'User does not have permission to add these expenses to the report'
    #     return false
    #   end
    #   expenses.update_all(report_id: report.id)
    # end
  end

  def remove_expense

  end

  def reject_expense

  end

  def edit_expense

  end

  def rename_report

  end

  def attach_receipt

  end

  def delete_report

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