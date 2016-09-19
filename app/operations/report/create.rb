# action to create a new report.
# params:
# name: optional, if creating a report with a name
# expense_ids: ids of the expenses that the report is to be created with

class Report::Create < Report::Base

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
    end
  end

  def init

  end

  def authorize

  end

  def process
    self.report = user.reports.build report_status_id: ReportStatus.open_id, controlling_user: user, name: params[:name]
    if report.save
      report_track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.create_id, report_status_id: ReportStatus.open_id
      report_track.save
      expense_ids = params[:expense_ids].split(',') if params[:expense_ids]
      if expense_ids.present?
        Report::Expenses::Add.(user, {report_id: report.id, expense_ids: expense_ids})
      end
    else
      messages[:error] = report.errors.full_messages
    end
  end

  def post_process
    messages[:success] << "Report created."
  end

end