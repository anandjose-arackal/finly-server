require 'test_helper'
require 'report_operation_test_helper'

class ApproveTest < ActiveSupport::TestCase

  def setup

  end

  test "Report approval flow" do
    user = User.find_by(email: 'user0@finlytest.io')
    report = dummy_report_flow user, submit: true
    controlling_user = report.controlling_user
    assert report.present?
    assert report.processing?

    # Report service approve will fail unless user is provided to it
    report_service = ReportService.new(report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.approve
    end
    assert report.processing?
    assert report_service.errors.present?

    # Report service approve will fail unless report is provided to it
    report_service = ReportService.new(user: user)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.approve
    end
    assert report.processing?
    assert report_service.errors.present?

    # Can only be approved by controlling manager
    report_service = ReportService.new(user: User.first, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.approve
    end
    assert report.processing?
    assert report_service.errors.present?

    # Can only be approved when in processing state
    r = dummy_report_flow user, create: true
    rs = ReportService.new(user: controlling_user, report: r)
    assert rs.errors.blank?
    assert r.open?
    assert_no_difference 'ReportTrack.count' do
      rs.approve
    end
    assert r.open?
    assert rs.errors.present?

    # Successful approval
    # After approval, if approving manager has a approves_to, report is still in processing state approves_to manager is assigned as the controlling manager
    report_service = ReportService.new(user: controlling_user, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert_not_equal report.controlling_user.id, controlling_user.id
    assert report_service.errors.blank?
    assert report.processing?
    approves_to = UserTeamService.new(controlling_user).approves_to(view: 'manager', report: report)
    assert approves_to.present?
    assert report.controlling_user.id, approves_to.id

    # After approval, if approving manager does not have approves_to assigned, report is still in processing state and finance manager is assigned as controlling manager
    assert report.processing?
    report_service = ReportService.new(user: approves_to, report: report)
    assert report_service.errors.blank?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert report.processing?
    finance_manager = UserTeamService.new(report.user).finance_manager(report: report)
    assert finance_manager.present?
    assert report.controlling_user.id, finance_manager.id

    # After finance approval, if approving manager has a finance_approves_to, report is still in processing state finance_approves_to manager is assigned as the controlling manager
    controlling_user = report.controlling_user
    report_service = ReportService.new(user: controlling_user, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert_not_equal report.controlling_user.id, controlling_user.id
    assert report_service.errors.blank?
    assert report.processing?
    approves_to = UserTeamService.new(controlling_user).approves_finance_to(view: 'manager', report: report)
    assert approves_to.present?
    assert report.controlling_user.id, approves_to.id

    # After final finance approval, report is marked as approved
    controlling_user = report.controlling_user
    report_service = ReportService.new(user: controlling_user, report: report)
    assert report_service.errors.blank?
    assert report.processing?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert report.controlling_user.blank?
    assert report_service.errors.blank?
    assert report.approved?

    # When auto-approval due to no manager or finance manager assigned, report is marked as approved and controlling user is set to nil
    u = User.first
    r = dummy_report_flow u, create_and_add_expenses: true
    assert UserTeamService.new(u).manager(report: r).blank?
    rs = ReportService.new(user: u, report: r)
    rs.submit
    assert r.approved?

    # After final approval, if the user does not have a finance manager assigned, report is set to approved state and left hanging for admin to take control
    assert r.controlling_user.blank?

    # When report is approved, if report contains reimbursable expenses, final finance manager is set as the controlling user of the report
    # When report is approved, if final approver is not a finance manager and report contains reimbursable expenses, reports controlling user is set as nil
    # Auto approval should set the tracking status as auto-approved and have nil as action_user
  end
end