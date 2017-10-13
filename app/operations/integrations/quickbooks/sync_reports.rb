class Integrations::Quickbooks::SyncReports < Integrations::Quickbooks::AsyncBase

  attr_accessor :reports, :temp_errors, :qb_reports, :date_type, :quickbooks_configuration, :company,
                :sync_status, :department_split, :department_field_configuration_ids, :quickbooks_departments

  def init
    super()
    self.company = Company.find_by(id: params[:company_id]) || user.company
    self.quickbooks_configuration = user.company.quickbooks_configuration
    user_ids = user.company.users.pluck(:id)
    self.reports = Report.with_user(user_ids).where(id: params[:report_ids])
    self.qb_reports = []
    self.department_split = {}
    self.date_type = quickbooks_configuration.transaction_date_field
    self.department_field_configuration_ids = []
    retrieve_department_field_configuration
    self.quickbooks_departments = company.quickbooks_departments
  end

  def self.call_async(user_id, params)
    super(user_id, params)
    user = User.find_by(id: user_id)
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, [])
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
      if report.synced_with_quickbooks?
        synced_report_names << report.name
      end
    end
    unless synced_report_names.empty?
      add_message :error, "Some of these reports are already synced with Quickbooks, please uncheck them and try again"
    end
  end


  def pre_process
    # splitting the reports into two sections (reimbursable and non-reimbursable) for syncing with quickbooks online
    # further, the reports will be split according to the respective departments that they're a part of
    reports.each do |report|
      # if the report is already synced, skip to the next one
      if report.synced_with_quickbooks?
        next
      end
      reimbursable_expenses = report.expenses.reimbursable
      # reimbursable_qb_report = non_reimbursable_qb_report = nil
      if reimbursable_expenses.present?
        self.department_split = generate_department_split(reimbursable_expenses)
        self.department_split.each do |key, value|

          department = QuickbooksDepartment.find_by(id: key)
          qb_report = QuickbooksReportConfig.new(report.user, true, value, {department_id: department&.quickbooks_id})
          if date_type == 1
            qb_report.date = reimbursable_expenses.reorder(date: :asc).first&.date
          elsif date_type == 2
            qb_report.date = reimbursable_expenses.reorder(date: :desc).first&.date
          end
          self.qb_reports << qb_report
        end
      end
      # adding reimbursable reports to the qb_report array
      # self.qb_reports << reimbursable_qb_report if reimbursable_qb_report
      non_reimbursable_expenses = report.expenses.non_reimbursable
      if non_reimbursable_expenses.present?
        self.department_split = generate_department_split(non_reimbursable_expenses)
        self.department_split.each do |key, value|
          department = QuickbooksDepartment.find_by(id: key)
          qb_report = QuickbooksReportConfig.new(report.user, false, value, {department_id: department&.quickbooks_id})
          if date_type == 1
            qb_report.date = non_reimbursable_expenses.reorder(date: :asc).first&.date
          elsif date_type == 2
            qb_report.date = non_reimbursable_expenses.reorder(date: :desc).first&.date
          end
          self.qb_reports << qb_report
        end
      end
      # adding non reimbursable reports to the qb_report array
      # self.qb_reports << non_reimbursable_qb_report if non_reimbursable_qb_report
    end
  end

  def process
    qb_reports.each do |qb_report|
      unless qb_report.expenses.not_synced_with_quickbooks.empty?
        result = adapter.save_report(qb_report)
        if result.is_a?(String)
          add_message :error, result
          if qb_report.report.expenses.pluck(:synced_with_quickbooks).include?(nil) || report.expenses.pluck(:synced_with_quickbooks).include?(false)
            if qb_report.report.expenses.pluck(:synced_with_quickbooks).include?(true)
              self.sync_status = 2
              qb_report.report.update(sync_status_id: ReportSyncStatus.id_for(:partially_synced))
            else
              self.sync_status = 1
              qb_report.report.update(sync_status_id: ReportSyncStatus.id_for(:not_synced))
            end
          end
        end
      end
    end
  end

  def post_process
    self.sync_status = 1
    reports.each do |report|
      if report.expenses.pluck(:synced_with_quickbooks).include?(nil) || report.expenses.pluck(:synced_with_quickbooks).include?(false)
        if report.expenses.pluck(:synced_with_quickbooks).include?(true)
          self.sync_status = 2
          report.update(sync_status_id: ReportSyncStatus.id_for(:partially_synced))
        else
          self.sync_status = 1
          report.update(sync_status_id: ReportSyncStatus.id_for(:not_synced))
        end
        next
      end
      report.update(sync_status_id: ReportSyncStatus.id_for(:synced))
    end
  end

  # this should create a successful notification entry saying the reports have been synced
  def success
    view_role = 1
    case self.sync_status
      when 1
        # fully synced
        user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                         action_type_id: NotificationActionType.id_for(:notify_quickbooks_sync_success),
                                         action_user_id: user.id,
                                         path_object_type: "Reports",
                                         object_type: "Report",
                                         read: false,
                                         timestamp: DateUtils.local_date_time,
                                         view_role_id: view_role,
                                         application: RequestStore.store[:current_app])
      when 2
        # partially synced
        user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                  action_type_id: NotificationActionType.id_for(:notify_quickbooks_sync_partial_success),
                                  action_user_id: user.id,
                                  path_object_type: "Reports",
                                  object_type: "Report",
                                  read: false,
                                  timestamp: DateUtils.local_date_time,
                                  view_role_id: view_role,
                                  application: RequestStore.store[:current_app])
    end
  end

  # this should create a failure notification entry saying the reports have not been synced
  def failure
    view_role = 1
    user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                       action_type_id: NotificationActionType.id_for(:notify_quickbooks_sync_failure),
                                       action_user_id: user.id,
                                       path_object_type: "Reports",
                                       object_type: "Report",
                                       read: false,
                                       timestamp: DateUtils.local_date_time,
                                       view_role_id: view_role,
                                       application: RequestStore.store[:current_app],
                                       message: messages[:error].to_sentence)
  end


  private

  # this method will take a bunch of expenses and split them according to quickbooks department
  def generate_department_split(expenses)
    expenses.each do |expense|
      department_value = expense.custom_fields.with_field_configuration_ids(self.department_field_configuration_ids).first&.value&.value&.name
      department = company.quickbooks_departments.with_name(department_value).first
      if department.present?
        if self.department_split[department.id].is_a?(Array)
          self.department_split[department.id] << expense
        else
          self.department_split[department.id] = []
          self.department_split[department.id] << expense
        end
      else
        if self.department_split[nil].is_a?(Array)
          self.department_split[nil] << expense
        else
          self.department_split[nil] = []
          self.department_split[nil] << expense
        end
      end
    end
    self.department_split
  end

  def retrieve_department_field_configuration
    company.field_configurations.each do |config|
      if config.external_reference.present? && config.external_reference_type.include?("QuickbooksReference") && config.external_reference.quickbooks_department?
        self.department_field_configuration_ids << config.id
      end
    end
  end
end