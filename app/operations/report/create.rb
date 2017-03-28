# action to create a new report.
# params:
# name: optional, if creating a report with a name
# expense_ids: ids of the expenses that the report is to be created with
# expenses: array of expense objects to be added to the report

class Report::Create < Report::Base
  attr_accessor :for_user

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.for_user = (params[:for_user] or user)
  end

  def authorize

  end

  def process
    role_id = UserRole.id_for(:employee)
    self.report = for_user.reports.build report_status_id: ReportStatus.open_id,
                                         controlling_user: for_user,
                                         controlling_user_role_id: role_id,
                                         policy_id: params[:policy_id],
                                         name: params[:name]
    if report.save
      report.tracks.create action_user: for_user,
                           action_user_role_id: role_id,
                           modified_user: for_user,
                           modified_user_role_id: role_id,
                           report_tracking_action_id: ReportTrackingAction.id_for(:create),
                           report_status_id: ReportStatus.open_id
      expenses = params[:expenses]
      expense_ids = nil

      if params[:expense_ids] and expenses.blank?
        expense_ids = params[:expense_ids].split(',')
      end
      if expense_ids.present? or expenses.present?
        Report::Expenses::Add.(user, {for_user: for_user, report: report, expenses: expenses, expense_ids: expense_ids})
      end

      CustomField::SetReport.(report, reset_fields: true, save: true)

    else
      add_message :error, report.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Report created'
  end

end