# == Schema Information
#
# Table name: reports
#
#  id                                 :integer          not null, primary key
#  name                               :string(255)      not null
#  user_id                            :integer          not null
#  report_status_id                   :integer          not null
#  policy_id                          :integer          not null
#  submitted_at                       :datetime
#  controlling_user_id                :integer
#  controlling_user_role_id           :integer
#  controlling_for_user_id            :integer
#  controlling_for_user_role_id       :integer
#  memo                               :string(255)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  reimbursement_id                   :integer
#  accounted                          :boolean          default(FALSE), not null
#  archived                           :boolean          default(FALSE), not null
#  is_deleted                         :boolean          default(FALSE), not null
#  auto_submit                        :boolean          default(FALSE), not null
#  auto_approve                       :boolean          default(FALSE), not null
#  accounted_at                       :date
#  approved_at                        :datetime
#  cash_in_hand_deduction_id          :integer
#  submitted_amount_id                :integer
#  reimbursable_expenses_total_id     :integer
#  card_expenses_total_id             :integer
#  non_reimbursable_expenses_total_id :integer
#  sync_status_id                     :integer
#  sync_type_id                       :integer
#  report_processor_group_mapping_id  :integer
#  travel_request_id                  :integer
#  created_by_id                      :integer
#



# requires a report with the following states in the db:
# a report in the db without expenses
# a report in the db with expenses


require 'test_helper'
require 'helpers/report_service_test_helper'

class ReportTest < ActiveSupport::TestCase

  def setup
    @report = Report.first
    @employee = users(:employee)
    @report_with_expenses = Report.second
  end

  test "report cannot exist without a name - creation or updation without a name " do
    @report.name = ""

    # mocking the report's owner as @employee
    @report.stubs(:user).returns(@employee)

    assert @report.save # it saves the report with a default name
    assert @report.name

    # creating a new report with no name
    create_op = Reports::Create.new(@employee)
    assert_difference 'Report.count', 1 do
      @result = create_op.run
    end

    assert @result.success?
    assert @result.report
    assert @result.report.name
  end

  test "destroying a report ensures the expenses are returned to unreported state and receipts are unassociated" do
    # mocking the report's and the owner as @employee
    @report_with_expenses.stubs(:user).returns(@employee)
    Expense.any_instance.stubs(:user).returns(@employee)

    report_expenses = @report_with_expenses.expenses
    @report_with_expenses.destroy

    report_expenses.each do |expense|
      assert_equal ExpenseStatus.unreported_id, expense.expense_status_id
    end

    # assert that the report is in deleted state
    @report_with_expenses.reload
    assert @report_with_expenses.is_deleted
  end


end
