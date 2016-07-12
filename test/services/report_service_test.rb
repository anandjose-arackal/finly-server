require 'test_helper'

require 'helpers/report_service_test_helper'
class ReportServiceTest < ActiveSupport::TestCase
  include ReportServiceTestHelper

  def setup

  end

  test 'creating new report' do
    report = nil
    user = User.last

    report_service = ReportService.new
    # Cannot create reports without user
    assert_no_difference 'Report.count' do
      assert_no_difference 'ReportTrack.count' do
        report = report_service.create
      end
    end
    assert report.blank?
    assert report_service.errors.present?

    # Successful creation
    assert_difference 'Report.count', 1 do
      assert_difference 'ReportTrack.count', 1 do
        report = ReportService.new(user: user).create
      end
    end
    assert report.present?
    assert report.is_a?(Report)
    assert_equal report.user.id, user.id
    assert report.name.present?
    assert report.status.id == ReportStatus.open_id

    # Can create report with a report name
    # Can create report with expenses pre-selected
  end

  test 'adding expenses to reports' do
    user = User.last
    report_service = ReportService.new(user: user)
    report = report_service.create
    assert report.present?

    report_service = ReportService.new(user: user, report: report)
    expense_service = ExpenseService.new(user)
    expenses = []
    assert_difference 'Expense.count', 5 do
      5.times.each do
        expenses << expense_service.add_expense(expense: {amount: Faker::Commerce.price, merchant: Faker::Company.name, expense_status_id: 1,
                                                          expense_type_id: 1, date: Date.today, currency_id: 1})
      end
    end
    assert_equal expenses.size, 5
    expenses.each do |expense|
      assert_nil expense.report_id
    end
    expenses = user.expenses.unreported
    report_service.add_expense(expenses)
    expenses.each do |expense|
      expense.reload
      assert_equal expense.report.id, report.id
    end

    # Only report owners can add expenses to report
    # Expenses can be added to report only when report is in open or retracted states
    # Expenses when added to report should clear manager memo and rejecting manager id
  end

  test 'removing expenses from report' do

  end

  test 'rejectable to users list' do

  end

  test 'report submission' do
    user = User.last

    report_service = ReportService.new(user: user)
    report = report_service.create

    # Reports can only be submitted if they have atleast one expense
    report_service = ReportService.new(user: User.first, report: report)
    assert report.expenses.blank?
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    add_dummy_expenses(user, report)

    # Report service submission will fail unless report is provided to it
    report_service = ReportService.new(user: user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    # Report service submission will fail unless user is provided to it
    report_service = ReportService.new(report: report)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    # Only the report owner can submit the report
    report_service = ReportService.new(user: User.first, report: report)
    assert report.open?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report.open?
    assert report_service.errors.present?

    # Successful submission with memo
    report_service = ReportService.new(user: user, report: report)
    assert report.open?
    memo = 'test memo l'
    assert_difference 'ReportTrack.count', 1 do
      report_service.submit(memo: memo)
    end
    report = report.reload
    report.tracks.reload
    assert report.processing?
    assert_equal report.memo, memo
    assert_equal report.tracks.last.memo, memo
    assert report_service.errors.blank?

    # Report can only be submitted in open/retracted state
    report_service = ReportService.new(user: user, report: report)
    assert report.processing?
    assert_no_difference 'ReportTrack.count' do
      report_service.submit
    end
    assert report_service.errors.present?

    # If report is submitted by a user who does not have a manager, it is auto approved

    # Submitting report should mark all expenses as submitted
  end

  test 'report retract flow' do
    user = User.last

    report = dummy_report_flow(user, submit: true)
    assert report.processing?
    assert_not_equal report.controlling_user.id, report.user.id

    # Report service retract will fail unless report is provided to it
    report_service = ReportService.new(user: user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report.processing?
    assert report_service.errors.present?

    # Report service retract will fail unless user is provided to it
    report_service = ReportService.new(report: report)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report.processing?
    assert report_service.errors.present?

    # Report can only be retracted by the user
    report_service = ReportService.new(report: report, user: report.controlling_user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report.processing?
    assert report_service.errors.present?

    # Successful retract
    report_service = ReportService.new(report: report, user: report.user)
    assert report_service.errors.blank?
    assert_difference 'ReportTrack.count', 1 do
      report_service.retract
    end
    assert report_service.errors.blank?
    assert report.retracted?

    # Report can only be retracted when in processing, approved states
    assert report.retracted?
    report_service = ReportService.new(report: report, user: report.user)
    assert report_service.errors.blank?
    assert_no_difference 'ReportTrack.count' do
      report_service.retract
    end
    assert report_service.errors.present?
    assert report.retracted?

    # Retracting report should mark all expenses as unsubmitted
  end

  test 'report approve flow' do
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

    # After approval, if approving manager does not have approves_to assigned, report is marked as approved and finance manager is assigned as controlling manager
    assert report.processing?
    report_service = ReportService.new(user: approves_to, report: report)
    assert report_service.errors.blank?
    assert_difference 'ReportTrack.count', 1 do
      report_service.approve
    end
    assert report.approved?
    finance_manager = UserTeamService.new(report.user).finance_manager(report: report)
    assert finance_manager.present?
    assert report.controlling_user.id, finance_manager.id

    # When auto-approval, report is marked as approved. If finance manager is assigned, finance manager is assigned as reports controlling user
    u = User.first
    r = dummy_report_flow u, create_and_add_expenses: true
    assert UserTeamService.new(u).manager(report: r).blank?
    rs = ReportService.new(user: u, report: r)
    rs.submit
    assert r.approved?

    # After final approval, if the user does not have a finance manager assigned, report is set to approved state and left hanging for admin to take control
    assert r.controlling_user.blank?

    # Auto approval should set the tracking status as auto-approved and have nil as action_user
    # todo track action ids verification
  end

  # todo test comments

end
