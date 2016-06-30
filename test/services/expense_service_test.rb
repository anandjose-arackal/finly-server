require 'test_helper'

class ExpenseServiceTest < ActiveSupport::TestCase

  def setup
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
    @user = User.first
    @es = ExpenseService.new(@user)
    @expense = @user.expenses.first
    @invalid_expense_params = {expense: {amount: 100,
                                         merchant: "Olacabs",
                                         note: "Sup dawg",
                                         expense_status_id: 1,
                                         expense_type_id: 1,
                                         date: Date.tomorrow,
                                         currency_id: 1},
                              }

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


end