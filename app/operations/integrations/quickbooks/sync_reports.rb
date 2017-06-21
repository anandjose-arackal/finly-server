class Integrations::Quickbooks::SyncReports < Integrations::Quickbooks::Base

  attr_accessor :reports, :temp_errors, :qb_reports

  def pre_validate
    if company.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super()
    user_ids = user.company.users.pluck(:id)
    self.reports = Report.with_user(user_ids).where(id: params[:report_ids])
    self.temp_errors = []
  end

  def validate
    # todo - check whether these reports are already synced with quickbooks in the first place
    # reports.each do |report|
    #   if report.synced_with_quickbooks
    #     reports.reject! {|r| r.id == report.id}
    #   end
    # end
  end

  def pre_process
    # splitting the reports into two sections for syncing with quickbooks online
    self.qb_reports = []
    reports.each do |report|
      # if the report is already synced, skip to the next one
      if report.synced_with_quickbooks
        next
      end
      reimbursable_expenses = report.expenses.reimbursable
      if reimbursable_expenses.present?
        qb_report = QuickbooksReportConfig.new
        qb_report.report = report
        qb_report.expenses = reimbursable_expenses
        qb_report.reimbursable = true
        qb_reports << qb_report
      end
      non_reimbursable_expenses = report.expenses.non_reimbursable
      if non_reimbursable_expenses.present?
        qb_report = QuickbooksReportConfig.new
        qb_report.report = report
        qb_report.expenses = non_reimbursable_expenses
        qb_report.reimbursable = false
        qb_reports << qb_report
      end
    end
  end

  def process
    qb_reports.each do |qb_report|
      result = adapter.save_report(qb_report)
      if result.is_a?(String)
        temp_errors << {report_id: qb_report.report.id, message: result}
      end
    end
  end

  def post_process
    # find a way to show the individual errors with the respective report names
  end
end