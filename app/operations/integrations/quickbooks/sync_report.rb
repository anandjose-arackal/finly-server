# this operation can take a single report id and sync that with quickbooks

class Integrations::Quickbooks::SyncReport < Integrations::Quickbooks::Base

  attr_accessor :report, :qb_reports

  def pre_validate
    if company.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super()
    self.report = params[:report]
    if report.blank?
      user_ids = company.users
      self.report = Report.with_user(user_ids).find_by(id: params[:report_id])
    end
    # now splitting the report into two - one with reimbursable and one with non-reimbursable expenses
    self.qb_reports = []
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

  def validate
    if report.synced_with_quickbooks
      add_message :error, "This report is already synced with quickbooks"
      return
    end
    unless report.processed?
      add_message :error, "Only processed reports can be synced to the accounting tool"
    end
  end

  def process
    qb_reports.each do |report|
      result = adapter.save_report(report)
      if result.is_a?(String)
        add_message :error, result
        return
      end
    end
  end

  def post_process
    # mark the report as synced with quickbooks so that you don't have to sync it again
    report.update(synced_with_quickbooks: true)

    add_message :success, "Report synced with quickbooks"
  end
end
