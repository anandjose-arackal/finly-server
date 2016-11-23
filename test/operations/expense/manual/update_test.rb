# requires one user of each type and one expense and report apiece for each of them

require 'test_helper'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @user = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @admin = users(:admin)
    @employee = users(:employee)
    @expense = @user.expenses.only_manual_expenses.first
    @update_params = {expense: {amount_attributes: {value: 1200, currency_id: 1},
                                manual_expense_attributes: {merchant: "Uber"},
                                note: "New note",
                                date: Date.yesterday},
                      id: @expense.id
                     }
    @invalid_expense_params = {expense: {amount_attributes: {value: 100, currency_id: 1},
                                         merchant: "Olacabs",
                                         note: "Sup dawg",
                                         date: Date.tomorrow},
                               id: "#{@expense.id}"
                              }
    @other_user = users(:manager)
    @other_expense = @other_user.expenses.first
    @receipt_params = {expense: {receipts_attributes: {image: @image}}}
    @receipt = Receipt::Create.(@user, {receipt: {image: @image}})
    @report = @user.reports.first
  end

  # test "updating an expense with valid parameters" do
  #   # mocking this expense to not be associated with a report
  #   Expense.any_instance.stubs(:report_id).returns(nil)
  #
  #   update_op = Expense::Manual::Update.new(@user, @update_params)
  #   assert_no_difference '@user.expenses.count' do
  #     @result = update_op.run
  #   end
  #   assert @result.success?
  #   assert_equal "Uber", @result.expense.merchant_name
  #   assert_equal Date.yesterday, @result.expense.date
  #   assert_equal 1200, @result.expense.amount_value
  # end
  #
  # test "updating an expense by attaching a receipt" do
  #   @receipt_params[:id] = @other_user.expenses.first.id
  #   update_op = Expense::Manual::Update.new(@other_user, @receipt_params)
  #   assert_no_difference '@user.expenses.count' do
  #     @result = update_op.run
  #   end
  #   assert @result.success?
  #   assert_not @result.expense.receipts.empty?
  #   assert_equal "1363397.png", @result.expense.receipts.first.image_file_name
  # end
  #
  # test "can't update an expenses with invalid parameters" do
  #   # making update params invalid
  #   # negative amount
  #   @update_params[:expense][:amount_attributes][:value] = -20
  #   update_op = Expense::Manual::Update.new(@user, @update_params)
  #   @result = update_op.run
  #   assert_not @result.success?
  #   assert_not @result.messages[:error].empty?
  #
  #   # future date
  #   @update_params[:expense][:date] = Date.tomorrow
  #   update_op = Expense::Manual::Update.new(@user, @update_params)
  #   @result = update_op.run
  #   assert_not @result.success?
  #   assert_not @result.messages[:error].empty?
  # end
  #
  # test "user cannot update another user's expenses" do
  #   # setting expense id as another users'
  #   @update_params[:id] = @other_expense.id
  #   update_op = Expense::Manual::Update.new(@user, @update_params)
  #   assert_no_difference '@user.expenses.count' do
  #     begin
  #       @result = update_op.run
  #     rescue NotAuthorizedException
  #       @rescued = true
  #     end
  #   end
  #   assert @rescued
  # end
  #
  # test "successfully editing an expense associated with a report that is open/retracted/rejected" do
  #   # mocking the expense belonging to a report and the fact that the report is in processing state
  #   Expense.any_instance.stubs(:report_id).returns(true)
  #   Expense.any_instance.stubs(:report).returns(@report)
  #   Report.any_instance.stubs(:open?).returns(true)
  #   Report.any_instance.stubs(:retracted?).returns(false)
  #   Report.any_instance.stubs(:rejected?).returns(false)
  #
  #   update_op = Expense::Manual::Update.new(@user, @update_params)
  #   assert_no_difference '@user.expenses.count' do
  #     @result = update_op.run
  #   end
  #   assert @result.success?
  #   assert_equal "Uber", @result.expense.merchant_name
  #   assert_equal Date.yesterday, @result.expense.date
  #   assert_equal 1200, @result.expense.amount_value
  # end
  #
  # test "cannot update an expense that is associated with a processing report" do
  #   # mocking the expense belonging to a report and the fact that the report is in processing state
  #   Expense.any_instance.stubs(:report_id).returns(true)
  #   Expense.any_instance.stubs(:report).returns(@report)
  #   Report.any_instance.stubs(:open?).returns(false)
  #   Report.any_instance.stubs(:retracted?).returns(false)
  #   Report.any_instance.stubs(:rejected?).returns(false)
  #
  #   update_op = Expense::Manual::Update.new(@user, @update_params)
  #   assert_no_difference '@user.expenses.count' do
  #     @result = update_op.run
  #   end
  #   assert_not @result.success?
  #   assert_not @result.messages[:error].empty?
  #   assert_equal "Report cannot be edited in this state", @result.messages[:error].first
  # end

  test "reporting manager can update a user's expense" do
    # stubbing the face that Expense Index returns the expense the manager needs to edit
    expenses_index_presenter = Expense::Index::ListPresenter.new(@admin, {expenses: Expense.where(id: @expense.id)}, nil)
    Expense::Index.stubs(:call).returns(expenses_index_presenter)

    @update_params[:view] = 'manager'
    update_op = Expense::Manual::Update.new(@manager, @update_params)
    assert_no_difference '@user.expenses.count' do
      @result = update_op.run
    end
    assert @result.success?
    assert_equal "Uber", @result.expense.merchant_name
    assert_equal Date.yesterday, @result.expense.date
    assert_equal 1200, @result.expense.amount_value
  end

  test "manager who's not in manager view cannot edit team member's expense" do
    # stubbing the face that Expense Index returns the expense the manager needs to edit
    expenses_index_presenter = Expense::Index::ListPresenter.new(@admin, {expenses: Expense.where(id: @expense.id)}, nil)
    Expense::Index.stubs(:call).returns(expenses_index_presenter)

    # no view passed to mimic personal view
    update_op = Expense::Manual::Update.new(@manager, @update_params)
    assert_no_difference '@user.expenses.count' do
      begin
        @result = update_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
  end

  test "non reporting manager cannot update a user's expense" do
    # mocking the fact that the expense index does not return the particular expense
    expenses_index_presenter = Expense::Index::ListPresenter.new(@admin, {expenses: []}, nil)
    Expense::Index.stubs(:call).returns(expenses_index_presenter)

    @update_params[:view] = 'manager'
    update_op = Expense::Manual::Update.new(@manager, @update_params)
    assert_no_difference '@user.expenses.count' do
      begin
        @result = update_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
  end

  test "admins can update anyone in the company's expenses" do
    # stubbing the fact that Expense Index returns the expense the manager needs to edit
    expenses_index_presenter = Expense::Index::ListPresenter.new(@admin, {expenses: Expense.where(id: @expense.id)}, nil)
    Expense::Index.stubs(:call).returns(expenses_index_presenter)

    @update_params[:view] = 'admin'
    update_op = Expense::Manual::Update.new(@admin, @update_params)
    assert_no_difference '@user.expenses.count' do
      @result = update_op.run
    end
    assert @result.success?
    assert_equal "Uber", @result.expense.merchant_name
    assert_equal Date.yesterday, @result.expense.date
    assert_equal 1200, @result.expense.amount_value
  end

end