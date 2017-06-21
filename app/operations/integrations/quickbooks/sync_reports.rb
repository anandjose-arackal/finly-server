class Integrations::Quickbooks::SyncReports < Integrations::Quickbooks::Base

  attr_accessor :reports, :temp_errors, :reimbursable_qb_report, :non_reimbursable_qb_report

  def pre_validate
    if company.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super()
    user_ids = user.company.users.pluck(:id)
    self.reports = Report.with_user(user_ids).where(id: params[:report_ids])
    self.reimbursable_qb_report = QuickbooksReportConfig.new(user, true)
    self.non_reimbursable_qb_report = QuickbooksReportConfig.new(user, false)
  end

  def validate
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
      end
      non_reimbursable_expenses = report.expenses.non_reimbursable
      if non_reimbursable_expenses.present?
        non_reimbursable_qb_report.expenses += non_reimbursable_expenses
      end
    end
  end

  def process
    result = adapter.save_report(reimbursable_qb_report)
    if result.is_a?(String)
      add_message :error, result
      return
    end
    result = adapter.save_report(non_reimbursable_qb_report)
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