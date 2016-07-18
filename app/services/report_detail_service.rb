class ReportDetailService < BaseService
  attr_accessor :report

  def initialize(report)
    super()
    self.report = report
  end

  def expenses
    report.expenses
  end

  def total_amount
    return report.expenses.with_amount.sum(:value).round(2) if report.expenses.present?
    0
  end

  def latest_expense
    return nil unless report.expenses.count > 0
    report.expenses.sort_latest_first.first
  end

  def policy
    PolicyRetrievalService.for_report(self.report)
  end

  def currency
    policy.configuration.report_currency
  end

  def controlling_user
    report.controlling_user
  end

  def controlling_for_user
    report.controlling_for_user
  end

  def controlling_user?(user)
    self.controlling_user.id == user.id
  end

end