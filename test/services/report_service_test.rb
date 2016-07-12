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
      assert_equal expense.report.id,report.id
    end

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
  end

  test 'report retract flow' do
    user = User.last

    report_service = ReportService.new(user: user)
    report = report_service.create
    report_service = ReportService.new(user: user, report: report)
    add_dummy_expenses(user, report)
    report_service.submit
    assert report.processing?

    # Report service submission will fail unless report is provided to it
    # Report service submission will fail unless user is provided to it
    # Report can only be retracted by the user
    # Report can only be retracted when in processing, approved states
    # Successful retract
  end

end
