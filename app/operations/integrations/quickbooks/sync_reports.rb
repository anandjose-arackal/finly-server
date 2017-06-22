class Integrations::Quickbooks::SyncReports < Integrations::Quickbooks::Base

  attr_accessor :reports, :temp_errors, :reimbursable_qb_report, :non_reimbursable_qb_report, :date_type, :quickbooks_configuration

  def init
    super()
    self.quickbooks_configuration = user.company.quickbooks_configuration
    user_ids = user.company.users.pluck(:id)
    self.reports = Report.with_user(user_ids).where(id: params[:report_ids])
    self.reimbursable_qb_report = QuickbooksReportConfig.new(user, true)
    self.non_reimbursable_qb_report = QuickbooksReportConfig.new(user, false)
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
      if reimbursable_expenses.present?
        reimbursable_qb_report.expenses += reimbursable_expenses
        if reimbursable_expenses.reorder(date: :asc).first&.date < reimbursable_qb_report.date && date_type == 1
          reimbursable_qb_report.date = reimbursable_expenses.reorder(date: :asc).first&.date
        elsif reimbursable_expenses.reorder(date: :desc).first&.date > reimbursable_qb_report.date && date_type == 2
          reimbursable_qb_report.date = reimbursable_expenses.reorder(date: :desc).first&.date
        end
      end
      non_reimbursable_expenses = report.expenses.non_reimbursable
      if non_reimbursable_expenses.present?
        non_reimbursable_qb_report.expenses += non_reimbursable_expenses
        non_reimbursable_qb_report.expenses += non_reimbursable_expenses
        if non_reimbursable_expenses.reorder(date: :asc).first&.date < non_reimbursable_qb_report.date && date_type == 1
          non_reimbursable_qb_report.date = non_reimbursable_expenses.reorder(date: :asc).first&.date
        elsif non_reimbursable_expenses.reorder(date: :desc).first&.date > non_reimbursable_expenses.date && date_type == 2
          non_reimbursable_qb_report.date = non_reimbursable_expenses.reorder(date: :desc).first&.date
        end
      end
    end
  end

  def process
    result = adapter.save_report(reimbursable_qb_report) unless reimbursable_qb_report.expenses.empty?
    if result.is_a?(String)
      add_message :error, result
      return
    end
    result = adapter.save_report(non_reimbursable_qb_report) unless non_reimbursable_qb_report.expenses.empty?
    if result.is_a?(String)
      add_message :error, result
      return
    end
  end

  def post_process
    # find a way to show the individual errors with the respective report names
    add_message :success, "Reports synced"
  end
end