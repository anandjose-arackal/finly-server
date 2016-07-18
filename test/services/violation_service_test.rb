require 'test_helper'

class ViolationServiceTest < ActiveSupport::TestCase

  def setup
    # setting up the rules and reports for the violation handler
    @user = User.first
    # report service to create and perform operations on report
    @report_service = ReportService.new user: @user
    @expenses = @user.expenses.limit(5)
    expense_ids = @expenses.pluck(:id)
    @policy = Policy.find(3)
    @create_report_params = {expenses: expense_ids}
    @report = @report_service.create(@create_report_params)
    @violation_service = ViolationService.new(@user)

    @image = File.open(Rails.root + "app/assets/images/1363397.jpg", "r")
    @receipt_params = {receipt: {image: @image}}
    @receipt_service = ReceiptService.new(@user)
  end

  test 'should return violations in the report' do
    @violation_service.violations(@policy, @report)

    assert @violation_service.warning_messages.present?

    # extracting the expenses that are above 50 and don't have a receipt
    expenses = @report.expenses.joins(:amount).where('value >= ?', 50)
    expenses.each do |expense|
      if expense.receipts_count == 0
        # ensuring that their violations have been recorded
        assert @violation_service.warning_messages[expense.id]['expense_warning'].present?
        @violating_expense = expense
      end
    end

    # checking if the budget warning has been properly detected
    ids = @report.expenses.pluck(:id)
    ids.each do |id|
      assert @violation_service.warning_messages[id]['budget_warning'].present?
      assert @violation_service.warning_messages[id]['budget_blocking'].present?
    end

    # adding receipt to one of violating expenses and ensuring it doesn't show up as an error hence

    # creating a new receipt and attaching it to the violating expense
    receipt = @receipt_service.create_receipt @receipt_params
    receipt.parent = @violating_expense
    receipt.save

    # running the violation generation again
    @violation_service.violations(@policy, @report)

    # asserting that the newly edited expense doesn't have an associated warning now
    assert @violation_service.warning_messages[@violating_expense.id]['expense_warning'].empty?

  end

  test 'report without policy should not return any violations' do
    @violation_service.violations(nil, @report)

    assert @violation_service.warning_messages.blank?

  end


  test 'adding a new expense that hence violates budget is accurately detected' do
    # fetching a new set of expenses that aren't associated with a report
    expenses = @user.expenses.where(report_id: nil).limit(5)

    # creating a report with just two expenses that don't violate the budget blocking rule
    expense_ids = expenses.limit(2).pluck(:id)
    report_params = {expenses: expense_ids}
    @report = @report_service.create(report_params)

    @violation_service.violations(@policy, @report)
    # ensuring the report doesn't have blocking violations on overall monthly budget
    ids = @report.expenses.pluck(:id)
    ids.each do |id|
      assert @violation_service.warning_messages[id]['budget_blocking'].empty?
    end

    # adding a third and fourth expense that will hence violate the budget rule
    @report_service.report = @report
    new_expense_id = [expenses.third.id]
    new_expense_id << [expenses.fourth.id]
    @report = @report_service.add_expense(new_expense_id)

    # now checking if the report detects the new budget violation
    @violation_service.violations(@policy, @report)
    ids = @report.expenses.pluck(:id)
    ids.each do |id|
      assert @violation_service.warning_messages[id]['budget_blocking'].present?
    end

  end

  test 'deleting a rule removes all violations associated with it' do

    # checking if the violations are initially present
    @violation_service.violations(@policy, @report)
    assert @violation_service.warning_messages.present?

    ids = @report.expenses.pluck(:id)
    ids.each do |id|
      assert_not @violation_service.warning_messages[id]['budget_blocking'].empty?
    end

    # deleting the overall budget rule
    BudgetRule.destroy(2)

    # checking if the violations are now removed
    @violation_service.violations(@policy, @report)
    
    ids = @report.expenses.pluck(:id)
    ids.each do |id|
      assert @violation_service.warning_messages[id]['budget_blocking'].empty?
    end

  end


end