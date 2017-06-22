class Integrations::Quickbooks::SyncReports < Integrations::Quickbooks::AsyncBase

  attr_accessor :reports, :temp_errors, :qb_reports, :date_type, :quickbooks_configuration, :company

  def init
    super()
    self.company = Company.find_by(id: params[:company_id])
    self.quickbooks_configuration = user.company.quickbooks_configuration
    user_ids = user.company.users.pluck(:id)
    self.reports = Report.with_user(user_ids).where(id: params[:report_ids])
    self.qb_reports = []
    self.date_type = quickbooks_configuration.transaction_date_field
  end

  def validate
    # if Quickbooks hasn't been configured yet, throw an error asking them to configure it
    unless user.company.quickbooks_configuration.present? && user.company.quickbooks_configuration.reimbursable_account_id.present? && user.company.quickbooks_configuration.non_reimbursable_account_id.present?
      add_message :error, "You have not configured quickbooks yet. Please do so from company account and try again"
      return
    end

    # ensure that all reports being synced are approved or above
    reports.each do |report|
      unless report.processed?
        add_message :error, "Only processed reports can be exported to Quickbooks. Some of these reports have not been processed yet"
        return
      end
    end

    # if any of the reports are already synced with quickbooks, stop the sync and mention their names
    synced_report_names = []
    reports.each do |report|
      if report.synced_with_quickbooks
        synced_report_names << report.name
      end
    end
    unless synced_report_names.empty?
      add_message :error, "Some of these reports are already synced with Quickbooks, please uncheck them and try again"
    end
  end


  def pre_process
    # splitting the reports into two sections for syncing with quickbooks online
    reports.each do |report|
      # if the report is already synced, skip to the next one
      if report.synced_with_quickbooks
        next
      end
      reimbursable_expenses = report.expenses.reimbursable
      reimbursable_qb_report = non_reimbursable_qb_report = nil
      if reimbursable_expenses.present?
        reimbursable_qb_report = QuickbooksReportConfig.new(user, true, reimbursable_expenses)
        if date_type == 1
          reimbursable_qb_report.date = reimbursable_expenses.reorder(date: :asc).first&.date
        elsif date_type == 2
          reimbursable_qb_report.date = reimbursable_expenses.reorder(date: :desc).first&.date
        end
      end
      # adding reimbursable reports to the qb_report array
      self.qb_reports << reimbursable_qb_report if reimbursable_qb_report
      non_reimbursable_expenses = report.expenses.non_reimbursable
      if non_reimbursable_expenses.present?
        non_reimbursable_qb_report = QuickbooksReportConfig.new(user, false, non_reimbursable_expenses)
        if date_type == 1
          non_reimbursable_qb_report.date = non_reimbursable_expenses.reorder(date: :asc).first&.date
        elsif date_type == 2
          non_reimbursable_qb_report.date = non_reimbursable_expenses.reorder(date: :desc).first&.date
        end
      end
      # adding non reimbursable reports to the qb_report array
      self.qb_reports << non_reimbursable_qb_report if non_reimbursable_qb_report
    end
  end

  def process
    qb_reports.each do |qb_report|
      unless qb_report.expenses.empty?
        result = adapter.save_report(qb_report)
        if result.is_a?(String)
          add_message :error, result
          return
        end
      end
    end
  end

  # this should create a successful notification entry saying the reports have been synced
  def success
    view_role = params[:view] == 'admin' ? 1 : 2
    user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                       action_type_id: NotificationActionType.id_for(:notify_quickbooks_sync_success),
                                       action_user_id: user.id,
                                       path_object_type: "Reports",
                                       object_type: "Report",
                                       read: false,
                                       timestamp: DateUtils.local_date_time,
                                       view_role_id: view_role)
    reports.each do |report|
      report.update(synced_with_quickbooks: true)
    end
  end

  # this should create a failure notification entry saying the reports have not been synced
  def failure
    view_role = params[:view] == 'admin' ? 1 : 2
    user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                       action_type_id: NotificationActionType.id_for(:notify_quickbooks_sync_failure),
                                       action_user_id: user.id,
                                       path_object_type: "Reports",
                                       object_type: "Report",
                                       read: false,
                                       timestamp: DateUtils.local_date_time,
                                       view_role_id: view_role,
                                       message: messages[:error].to_sentence)
  end
end