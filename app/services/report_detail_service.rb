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
    report.expenses.with_amount.sum(:value)
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