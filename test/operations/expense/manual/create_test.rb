require 'test_helper'

class CreateTest < ActiveSupport::TestCase

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
    @invalid_expense_params = {expense: {amount: 100,
                                         merchant: "Olacabs",
                                         note: "Sup dawg",
                                         expense_status_id: 1,
                                         expense_type_id: 1,
                                         date: Date.tomorrow,
                                         currency_id: 1},
    }

    @user = User.first
    @expense = @user.expenses.first
  end

  test 'creating an expense' do
    create_op = Expense::Manual::Create.new(@user, @expense_params)
    assert_difference '@user.expenses.count', 1 do
      @expense = create_op.run
    end
    assert_equal "Olacabs", @expense.merchant_name
    assert_equal DateUtils.local_date, @expense.date

    # creating an expense with receipt
    @expense_params[:expense][:receipt] = @image
    create_op = Expense::Manual::Create.new(@user, @expense_params)
    assert_difference '@user.expenses.count', 1 do
      @expense = create_op.run
    end
    assert_equal "Olacabs", @expense.merchant_name
    assert_equal DateUtils.local_date, @expense.date
    assert @expense.receipts.count
  end

  test 'trying to create an expense with incompatible parameters' do
    # future date
    create_op = Expense::Manual::Create.new(@user, @invalid_expense_params)
    assert_no_difference '@user.expenses.count' do
      @expense = create_op.run
    end
    assert_not @expense
    assert_not create_op.errors.empty?

    # negative amount
    @invalid_expense_params[:expense][:amount] = -10
    create_op = Expense::Manual::Create.new(@user, @invalid_expense_params)
    assert_no_difference '@user.expenses.count' do
      @expense = create_op.run
    end
    assert_not @expense
    assert_not create_op.errors.empty?

  end

end