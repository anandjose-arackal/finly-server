require 'test_helper'
require 'helpers/report_operation_test_helper'

class AddExpensesTest < ActiveSupport::TestCase

  def setup
    @employee = User.first
    @report = @employee.reports.first
    @expenses = @employee.expenses.unreported.limit(2)
    @expense_ids = @expenses.pluck(:id)
    @expense_params = {expense: {amount_attributes: {value: "100", currency_id: 1},
                                 manual_expense_attributes: {merchant: "Olacabs"},
                                 note: "Sup dawg",
                                 date: DateUtils.local_date,
                                 category_id: 1,
                                 report_id: @report.id}
    }
  end

  test "successful adding of existing expenses to an open report" do

    # mocking report's open state
    Report.any_instance.stubs(:open?).returns(true)
    # stubbing Report Index so that the given report is returned for submission
    reports_presenter = Report::Index::Presenter.new(@employee, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)

    add_expenses_op = Report::Expenses::Add.new(@employee, {report_id: @report.id, expense_ids: @expense_ids})
    assert_difference '@report.expenses.count', 2 do
      @result = add_expenses_op.run
    end
    assert @result.success?
    assert ExpenseStatus.unsubmitted_id, @expenses.first.expense_status_id
    assert ExpenseStatus.unsubmitted_id, @expenses.second.expense_status_id
  end

  test "successful adding of a new expense to an open report" do
    # mocking report's open state
    Report.any_instance.stubs(:open?).returns(true)
    # stubbing Report Index so that the given report is returned for submission
    reports_presenter = Report::Index::Presenter.new(@employee, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)

    create_expense_op = Expense::Manual::Create.new(@employee, @expense_params)
    assert_difference '@report.expenses.count', 1 do
      @result = create_expense_op.run
    end
    assert @result.success?
    assert_equal ExpenseStatus.unsubmitted_id, @result.expense.expense_status_id

  end

  test "successfully adding expenses to a rejected report" do
    # mocking report's open state
    Report.any_instance.stubs(:rejected?).returns(true)
    # stubbing Report Index so that the given report is returned for submission
    reports_presenter = Report::Index::Presenter.new(@employee, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)

    # adding a new expense
    create_expense_op = Expense::Manual::Create.new(@employee, @expense_params)
    assert_difference '@report.expenses.count', 1 do
      @result = create_expense_op.run
    end
    assert @result.success?
    assert_equal ExpenseStatus.unsubmitted_id, @result.expense.expense_status_id

    # adding existing expenses
    add_expenses_op = Report::Expenses::Add.new(@employee, {report_id: @report.id, expense_ids: @expense_ids})
    assert_difference '@report.expenses.count', 2 do
      @result = add_expenses_op.run
    end
    assert @result.success?
    assert ExpenseStatus.unsubmitted_id, @expenses.first.expense_status_id
    assert ExpenseStatus.unsubmitted_id, @expenses.second.expense_status_id

  end

  test "successfully adding existing expenses to a retracted report" do
    # mocking report's open state
    Report.any_instance.stubs(:retracted?).returns(true)
    # stubbing Report Index so that the given report is returned for submission
    reports_presenter = Report::Index::Presenter.new(@employee, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)

    # adding a new expense
    create_expense_op = Expense::Manual::Create.new(@employee, @expense_params)
    assert_difference '@report.expenses.count', 1 do
      @result = create_expense_op.run
    end
    assert @result.success?
    assert_equal ExpenseStatus.unsubmitted_id, @result.expense.expense_status_id

    # add an existing expense
    add_expenses_op = Report::Expenses::Add.new(@employee, {report_id: @report.id, expense_ids: @expense_ids})
    assert_difference '@report.expenses.count', 2 do
      @result = add_expenses_op.run
    end
    assert @result.success?
    assert ExpenseStatus.unsubmitted_id, @expenses.first.expense_status_id
    assert ExpenseStatus.unsubmitted_id, @expenses.second.expense_status_id

  end

  test "cannot add expenses to a report that's not in open/retracted/rejected state" do
    # mocking report's state as not open, retracted or rejected
    Report.any_instance.stubs(:open?).returns(false)
    Report.any_instance.stubs(:rejected?).returns(false)
    Report.any_instance.stubs(:retracted?).returns(false)
    # stubbing Report Index so that the given report is returned for submission
    reports_presenter = Report::Index::Presenter.new(@employee, {reports: Report.where(id: @report.id)}, nil)
    Report::Index.stubs(:call).returns(reports_presenter)

    # failed attempt at adding a new expense
    create_expense_op = Expense::Manual::Create.new(@employee, @expense_params)
    assert_no_difference '@report.expenses.count' do
      @result = create_expense_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?

    # failed attempt at adding existing expenses
    add_expenses_op = Report::Expenses::Add.new(@employee, {report_id: @report.id, expense_ids: @expense_ids})
    assert_no_difference '@report.expenses.count' do
      @result = add_expenses_op.run
    end
    assert_not @result.success?
    assert ExpenseStatus.unreported_id, @expenses.first.expense_status_id
    assert ExpenseStatus.unreported_id, @expenses.second.expense_status_id
  end

  test "adding expenses to another's report should fail" do
    # mocking ownership of the report as some other user
    Report.any_instance.stubs(:user_id).returns(User.second.id)

    add_expenses_op = Report::Expenses::Add.new(@employee, {report_id: @report.id, expense_ids: @expense_ids})
    assert_no_difference '@report.expenses.count' do
      @result = add_expenses_op.run
    end
    assert_not @result.success?
    assert ExpenseStatus.unreported_id, @expenses.first.expense_status_id
    assert ExpenseStatus.unreported_id, @expenses.second.expense_status_id
  end

  test "" do

  end

end