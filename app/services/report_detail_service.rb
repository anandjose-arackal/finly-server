class ReportDetailService < BaseService
  include MathUtil
  attr_accessor :report

  def initialize(report)
    super()
    self.report = report
  end

  def expenses
    report.expenses
  end

  def total_amount
    return precision_value(report.expenses.with_amount.sum(:value)) if report.expenses.present?
    0
  end

  def final_approver
    return nil unless report.approved? or report.reimbursed? or report.reimbursement_confirmed? or report.closed?
    tracks = report.tracks.with_action(ReportTrackingAction.approve_id)
    if tracks.present?
      return tracks.last.action_user
    end
    nil
  end

  def first_date
    return nil unless report.expenses.count > 0
    report.expenses.sort_date_asc.first.date
  end

  def last_date
    return nil unless report.expenses.count > 0
    report.expenses.sort_date_desc.first.date
  end

  def date_as_string
    d_start = first_date
    d_end = last_date
    if d_start.blank? and d_end.blank?
      return ''
    end
    if d_start == d_end
      return "#{d_start.strftime("%d-%b-%y")}"
    else
      return "#{d_start.strftime("%d-%b-%y")} to #{d_end.strftime("%d-%b-%y")}"
    end
  end

  def latest_expense
    return nil unless report.expenses.count > 0
    report.expenses.sort_date_desc.first
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