require 'test_helper'


class AddReceiptTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @expense = @user.expenses.first
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
    @new_expense = Expense::Manual::Create.new(@user, @expense_params).run
    @receipt_params = {receipt: {image: @image},
                       expense_id: @new_expense.id
                      }
    @other_expense = User.second.expenses.first
    @other_receipt_params = {receipt: {image: @image},
                            expense_id: @other_expense.id
    }
  end

  test 'adding receipt to an expense' do
    @add_receipt_op = Expense::AddReceipt.new(@user, @receipt_params)
    assert_equal 0, @new_expense.receipts.count
    assert_difference '@new_expense.receipts.count', 1 do
      @receipt = @add_receipt_op.run
    end
    assert @receipt
    assert_equal @receipt.parent_id, @new_expense.id
  end

  test "cannot add receipt to someone else's expense" do
    @add_receipt_op = Expense::AddReceipt.new(@user, @other_receipt_params)
    assert_no_difference '@other_expense.receipts.count' do
      @receipt = @add_receipt_op.run
    end
    assert_not @receipt
    assert_not @add_receipt_op.errors.empty?
  end

  test "if expense already contains a receipt, it's replaced" do
    assert_not @expense.receipts.empty?
    old_receipt = @expense.receipts.first

    # resetting receipt params to the expense with receipts
    @receipt_params[:expense_id] = @expense.id
    @add_receipt_op = Expense::AddReceipt.new(@user, @receipt_params)
    assert_equal 1, @expense.receipts.count
    # no difference because the receipt is getting replaced
    assert_no_difference '@expense.receipts.count' do
      @receipt = @add_receipt_op.run
      old_receipt.reload
    end
    assert @receipt
    assert_equal @receipt.parent_id, @expense.id
    assert_not old_receipt.parent
  end

end