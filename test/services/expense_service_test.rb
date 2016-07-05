require 'test_helper'

class ExpenseServiceTest < ActiveSupport::TestCase

  def setup
    @image = File.open(Rails.root + "app/assets/images/1363397.jpg", "r")
    @expense_params = {expense: {amount: 100,
                                 merchant: "Olacabs",
                                 note: "Sup dawg",
                                 expense_status_id: 1,
                                 expense_type_id: 1,
                                 date: Date.today,
                                 currency_id: 1},
                      }
    @update_params = {expense: {amount: 1200,
                                merchant: "Uber",
                                note: "New note",
                                expense_status_id: 2,
                                expense_type_id: 1,
                                date: Date.yesterday,
                                currency_id: 1},
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
    @other_user = User.second
    @es = ExpenseService.new(@user)
    @expense = @user.expenses.first
    @second_expense = @user.expenses.second
    @other_expense = @other_user.expenses.first
    @receipt_params = {receipt: {image: @image}}
    @receipt = @expense.receipts.first
    @second_receipt = Receipt.create(user_id: 1, image: File.open(Rails.root + "app/assets/images/1363397.jpg", "r"))
  end

  test 'cannot create expense in the future' do
    assert_no_difference '@user.expenses.count' do
      expense = @es.add_expense @invalid_expense_params
    end
  end

  test 'should create and edit an expense from params' do
    expense = nil
    assert_difference '@user.expenses.count', 1 do
      expense = @es.add_expense @expense_params
      assert expense
    end

    # editing the expense
    @update_params[:expense][:id] = expense.id
    edited_expense = @es.update_expense(@update_params)
    assert_equal "Uber", edited_expense.merchant_name
    assert_equal "New note", edited_expense.note
    assert_equal Date.yesterday, edited_expense.date

  end

  test 'should destroy an expense from id' do
    assert Expense.exists?(id: @expense.id)
    assert_difference '@user.expenses.count', -1 do
      result = @es.remove_expense(@expense.id)
      assert result
      assert_not Expense.exists?(id: @expense.id)
    end
  end

  test "should return a user's expenses with manual expense details" do
    expenses = @es.user_expenses
    assert "Uber", expenses.first.merchant_name
  end

  test 'must add a receipt to an expense' do
    receipt = nil
    assert_difference '@expense.receipts.count', 1 do
      receipt = @es.add_receipt_to_expense(@receipt_params, @expense.id)
    end
    assert_equal @expense.id, receipt.parent.id # i.e. receipt has successfully been associated with expense
    assert_equal receipt.user.id, @user.id # i.e. receipt still belongs to user
  end

  test 'must detach an existing receipt from expense' do
    assert_difference '@expense.receipts.count', -1 do
      @receipt = @es.detach_receipt_from_expense(@receipt.id, @expense.id)
    end
    assert_not @receipt.parent # i.e. receipt has successfully been dissociated with expense
    assert_equal @receipt.user.id, @user.id # i.e. receipt still belongs to user
  end

  test 'must attach an existing receipt to an expense' do
    assert_equal 0, @second_expense.receipts.count, "Expense already has receipts." # i.e. no receipts associated with this expense
    assert_nil @second_receipt.parent # i.e. the receipt does not have a parent
    assert_difference '@second_expense.receipts.count', 1 do
      @second_receipt = @es.attach_receipt_to_expense(@second_receipt.id, @second_expense.id)
    end
    assert_not_nil @second_receipt.parent, "Receipt not assigned a parent."
    assert_equal @second_expense.id, @second_receipt.parent.id
  end

  test "cannot attach receipt to someone else's expense" do

  end

end