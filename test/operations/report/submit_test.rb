require 'test_helper'

class SubmitTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @employee = User.find(13)
    @manager0 = User.find_by(email: 'manager0@finlytest.io')
    @manager3 = User.find_by(email: 'manager3@finlytest.io')
    @second_employee = User.with_roles.only_employees.second
    @report = @employee.reports.open.first
    @second_employees_report = @second_employee.reports.open.first
  end

  test "successfully submitting a report with amount less than 1000" do

    # report with amount < 1000
    Report.any_instance.stubs(:total_amount).returns(800)
    submit_op = Report::Submit.new(@employee, {id: @report.id})
    assert_difference '@employee.reports.open.count', -1 do
      @result = submit_op.run
    end
    @report.reload
    assert_equal ReportStatus.processing_id, @report.status_id
    assert_equal @report.controlling_user_id, @manager0.id
  end

  test "successfully submitting a report with amount greater than 1000" do

    # report with amount > 1000
    Report.any_instance.stubs(:total_amount).returns(1200)
    submit_op = Report::Submit.new(@employee, {id: @report.id})
    assert_difference '@employee.reports.open.count', -1 do
      @result = submit_op.run
    end
    @report.reload
    assert_equal ReportStatus.processing_id, @report.status_id
    assert_equal @report.controlling_user_id, @manager3.id
  end

  test "cannot submit another user's report" do
    Report.any_instance.stubs(:user_id).returns(@second_employee.id)
    submit_op = Report::Submit.new(@employee, {id: @report.id})
    begin
      @result = submit_op.run
    rescue NotAuthorizedException
      @rescued = true
    end
    @report.reload
    assert_equal ReportStatus.open_id, @report.status_id
    assert @rescued
  end

  test "can only submit a report that's in open, rejected or retracted state" do
    # stubbing the report status as not open, retracted or rejected
    Report.any_instance.stubs(:open?).returns(false)
    Report.any_instance.stubs(:retracted?).returns(false)
    Report.any_instance.stubs(:rejected?).returns(false)
    submit_op = Report::Submit.new(@employee, {id: @report.id})
    assert_no_difference '@employee.reports.open.count' do
      @result = submit_op.run
    end
    @report.reload
    assert_equal ReportStatus.open_id, @report.status_id
  end

  test "cannot submit a report that has blocking violations" do
    # constructing the violations messages hash with a blocking violation
    warning_messages = {}
    @report.expenses.each do |expense|
      warning_messages[expense.id] = {}
      warning_messages[expense.id]['expense_warning'] = []
      warning_messages[expense.id]['expense_blocking'] = [{type: 'receipt', message: "Some shitty violation"}]
      warning_messages[expense.id]['budget_warning'] = []
      warning_messages[expense.id]['budget_blocking'] = [{type: 'receipt', message: "Some shitty violation"}]
    end
    Report::Violation.stubs(:call).returns(warning_messages)

    submit_op = Report::Submit.new(@employee, {id: @report.id})
    assert_no_difference '@employee.reports.open.count' do
      @result = submit_op.run
    end
    @report.reload
    assert_equal ReportStatus.open_id, @report.status_id
  end

  test "can submit a report that has warning violations" do
    # constructing the violations messages hash with a blocking violation
    warning_messages = {}
    @report.expenses.each do |expense|
      warning_messages[expense.id] = {}
      warning_messages[expense.id]['expense_warning'] = [{type: 'receipt', message: "Some shitty violation"}]
      warning_messages[expense.id]['expense_blocking'] = []
      warning_messages[expense.id]['budget_warning'] = [{type: 'receipt', message: "Some shitty violation"}]
      warning_messages[expense.id]['budget_blocking'] = []
    end
    Report::Violation.stubs(:call).returns(warning_messages)

    # report should go to processing state
    submit_op = Report::Submit.new(@employee, {id: @report.id})
    assert_difference '@employee.reports.open.count', -1 do
      @result = submit_op.run
    end
    @report.reload
    assert_equal ReportStatus.processing_id, @report.status_id
  end

  test "cannot submit a report that's empty" do
    Report.any_instance.stubs(:expenses).returns([])
    submit_op = Report::Submit.new(@employee, {id: @report.id})
    assert_no_difference '@employee.reports.open.count' do
      @result = submit_op.run
    end
    @report.reload
    assert_equal ReportStatus.open_id, @report.status_id
  end

end