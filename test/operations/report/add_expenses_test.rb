require 'test_helper'
require 'helpers/report_operation_test_helper'

class AddExpensesTest < ActiveSupport::TestCase

  def setup
    @employee = User.first
    @expense_ids = @employee.expenses.unreported.limit(2).pluck(:id)
  end

  test "successful adding of expenses to an open report" do

    create_op = Report::Create.new(@employee)
    @report = create_op.run
    assert @report.expenses.blank?
    assert @report.open?

    add_expenses_op = Report::Expenses::Add.new(@employee, {report_id: @report.id, expense_ids: @expense_ids})
    assert_difference '@report.expenses.count', 2 do
      @report = add_expenses_op.run
    end
    assert @report
    assert @report.total_amount > 0

    # approving the report - will be auto approved as this is admin
    submit_op = Report::Submit.new(@employee, report_id: @report.id)
    assert_difference 'ReportTrack.count', 1 do
      @report = submit_op.run
    end
    assert_equal ReportStatus.approved_id, @report.status_id
    assert_not @report.controlling_user_id

    @expense_ids = @employee.expenses.unreported.limit(2).pluck(:id)
    # adding expenses now will fail because report is already approved
    add_expenses_op = Report::Expenses::Add.new(@employee, {report_id: @report.id, expense_ids: @expense_ids})
    assert_no_difference '@report.expenses.count', 1 do
      @result = add_expenses_op.run
    end
    assert_not @result
    assert_equal 2, @report.expenses.count
  end


  test "Adding expenses to another's report should fail" do

  end
end