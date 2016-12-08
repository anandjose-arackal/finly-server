require 'test_helper'

class CreateManualExpenseTest < ActiveSupport::TestCase

  def setup
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @expense_params = {expense: {amount_attributes: {value: "100", currency_id: 1},
                                 manual_expense_attributes: {merchant: "Olacabs"},
                                 note: "Sup dawg",
                                 date: DateUtils.local_date,
                                 category_id: 1 }
                      }
    @invalid_expense_params = {expense: {amount_attributes: { value: 100, currency_id: 1},
                                         manual_expense_attributes: {merchant: "Olacabs"},
                                         note: "Sup dawg",
                                         date: Date.tomorrow},
    }

    @user = User.first
    @expense = @user.expenses.first
    @receipt = @user.receipts.without_parent.first
    @receipt = Receipt::Create.(@user, {receipt: {image: @image}}).receipt

  end

  test "successfully creating an expense with valid parameters" do
    create_op = Expense::Manual::Create.new(@user, @expense_params)
    assert_difference '@user.expenses.count', 1 do
      @result = create_op.run
    end
    assert_equal "Olacabs", @result.expense.merchant_name
    assert_equal DateUtils.local_date, @result.expense.date
    assert_equal 100, @result.expense.amount_value
  end

  test "creating an expense with a receipt" do
    @expense_params[:expense][:receipts_attributes] = {}
    @expense_params[:expense][:receipts_attributes][:image] = @image
    create_op = Expense::Manual::Create.new(@user, @expense_params)
    assert_difference '@user.expenses.count', 1 do
      @result = create_op.run
    end
    assert_equal "Olacabs", @result.expense.merchant_name
    assert_equal DateUtils.local_date, @result.expense.date
    assert_equal 100, @result.expense.amount_value
    assert_equal 1, @result.expense.receipts.count
    assert_equal "1363397.png", @result.expense.receipts.first.image_file_name
  end

  test "trying to create an expense with incompatible parameters - future date, negative amount and no category" do
    # future date
    create_op = Expense::Manual::Create.new(@user, @invalid_expense_params)
    assert_no_difference '@user.expenses.count' do
      @result = create_op.run
    end
    assert_not @result.success?

    # negative amount
    @invalid_expense_params[:expense][:amount_attributes][:value] = -10
    create_op = Expense::Manual::Create.new(@user, @invalid_expense_params)
    assert_no_difference '@user.expenses.count' do
      @result = create_op.run
    end
    assert_not @result.success?

  end

  test "creating an expense from a receipt id" do
    @expense_params[:receipt_id] = @receipt.id
    create_op = Expense::Manual::Create.new(@user, @expense_params)
    assert_difference '@user.expenses.count', 1 do
      assert_difference '@user.receipts.without_parent.count', -1 do
        @result = create_op.run
      end
    end
    @receipt.reload
    assert_equal @receipt.parent_id, @result.expense.id
    assert_equal @receipt.parent_type, "Expense"
    assert_equal "Olacabs", @result.expense.merchant_name
    assert_equal DateUtils.local_date, @result.expense.date
    assert_equal 100, @result.expense.amount_value
  end

  test "" do

  end

end