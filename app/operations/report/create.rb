class Report::Create < BaseOperation


  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank?
      errors << "User or params not passed."
    end
  end


  def process
    self.report = user.reports.build status: ReportStatus.open, controlling_user: user, name: params[:name]
    unless report.save
      report_track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.create_id, report_status_id: ReportStatus.open_id
      report_track.save
      if params[:expense_id].present?
        add_expense_op = Report::Expense::Add.new(params[:expense_id])
        unless add_expense_op.run
          errors << "Couldn't add expenses. Please add them manually later."
          return false
        end
      end
      return report
    end
    errors << report.errors.full_messages
  end


  def post_process

  end

end