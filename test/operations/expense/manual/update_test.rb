require 'test_helper'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @expense_params = {expense: {amount: 100,
                                 merchant: "Olacabs",
                                 note: "Sup dawg",
                                 expense_status_id: 1,
                                 expense_type_id: 1,
                                 date: DateUtils.local_date,
                                 currency_id: 1,
                                 category_id: 1 }
    }
    @user = User.first
    @expense = @user.expenses.first
    @update_params = {expense: {amount: 1200,
                                merchant: "Uber",
                                note: "New note",
                                expense_type_id: 1,
                                date: Date.yesterday,
                                currency_id: 1},
                      expense_id: @expense.id
    }
    @invalid_expense_params = {expense: {amount: 100,
                                         merchant: "Olacabs",
                                         note: "Sup dawg",
                                         expense_status_id: 1,
                                         expense_type_id: 1,
                                         date: Date.tomorrow,
                                         currency_id: 1},
    }

    @other_user = User.second
    @other_expense = @other_user.expenses.first
    @receipt_params = {receipt: {image: @image}}
    @receipt = @expense.receipts.first
  end

  test 'updating expense with valid parameters' do
    update_op = Expense::Manual::Update.new(@user, @update_params)
    @expense = update_op.run
    assert_equal "Uber", @expense.merchant_name
    assert_equal Date.yesterday, @expense.date
    assert_equal 1200, @expense.amount_value
  end

  test 'updating expenses with invalid parameters' do
    # making update params invalid
    #negative amount
    @update_params[:expense][:amount] = -20
    update_op = Expense::Manual::Update.new(@user, @update_params)
    @expense = update_op.run
    assert_not @expense
    assert_not update_op.errors.empty?

    # future date
    @update_params[:expense][:date] = Date.tomorrow
    update_op = Expense::Manual::Update.new(@user, @update_params)
    @expense = update_op.run
    assert_not @expense
    assert_not update_op.errors.empty?
  end

  test 'user cannot update another user\'s expenses' do
    # setting expense id as another users'
    @update_params[:expense_id] = @other_expense.id
    update_op = Expense::Manual::Update.new(@user, @update_params)
    @expense = update_op.run
    assert_not @expense
    assert_not update_op.errors.empty?
  end

end