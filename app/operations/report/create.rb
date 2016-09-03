# action to create a new report.
# params:
# name: optional, if creating a report with a name
# expense_ids: ids of the expenses that the report is to be created with

class Report::Create < Report::Base

  def authorized_user_types
    [:employee]
  end

  def init
    # nothing to retrieve, so empty
  end

  def authorize
    # nothing to authorize here.
  end

  def pre_validate
    if user.blank?
      errors << "User not passed."
    end
  end


  def process
    self.report = user.reports.build status: ReportStatus.open, controlling_user: user, name: params[:name]
    if report.save
      report_track = report.tracks.build action_user: user, report_tracking_action_id: ReportTrackingAction.create_id, report_status_id: ReportStatus.open_id
      report_track.save
      if params[:expense_ids].present?
        add_expense_op = Report::Expenses::Add.new(user, {report_id: report.id, expense_ids: params[:expense_ids]})
        unless add_expense_op.run
          # empty report gets created and is returned
          return report
        end
      end
      return report
    end
    errors << report.errors.full_messages
  end

end
