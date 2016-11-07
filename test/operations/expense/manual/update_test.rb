require 'test_helper'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @user = User.first
    @expense = @user.expenses.unreported.only_manual_expenses.first
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
    @other_user = User.second
    @other_expense = @other_user.expenses.first
    @receipt_params = {expense: {receipts_attributes: {image: @image}}}
    @receipt = @expense.receipts.first
  end

  test "updating an expense with valid parameters" do
    update_op = Expense::Manual::Update.new(@user, @update_params)
    assert_no_difference '@user.expenses.count' do
      @result = update_op.run
    end
    assert_equal "Uber", @result.expense.merchant_name
    assert_equal Date.yesterday, @result.expense.date
    assert_equal 1200, @result.expense.amount_value
  end

  test "can't update an expenses with invalid parameters" do
    # making update params invalid
    # negative amount
    @update_params[:expense][:amount_attributes][:value] = -20
    update_op = Expense::Manual::Update.new(@user, @update_params)
    @result = update_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?

    # future date
    @update_params[:expense][:date] = Date.tomorrow
    update_op = Expense::Manual::Update.new(@user, @update_params)
    @result = update_op.run
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
  end

  test "user cannot update another user's expenses" do
    # setting expense id as another users'
    @update_params[:id] = @other_expense.id
    update_op = Expense::Manual::Update.new(@user, @update_params)
    assert_no_difference '@user.expenses.count' do
      begin
        @result = update_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
  end

end