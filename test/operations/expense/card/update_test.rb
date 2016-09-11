require 'test_helper'
require_relative '../../../../lib/operations/expense/card/update'
require_relative '../../../../lib/operations/expense/card/create'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @transaction = @user.card_transactions.first
    @card = @transaction.card
    # creating a card expense first
    @expense = Expense::Card::Create.new(@transaction, @card).run
    @update_expense_params = {expense: {merchant: "Olacabs",
                                       receipt: @image},
                             expense_id: @expense.id
                            }
    @invalid_update_params = {expense: {date: Date.yesterday,
                                        amount: 200,
                                        expense_status_id: 3},
                              expense_id: @expense.id
                             }
  end

  test 'update a a card expense' do

    # checking previous card expense values
    assert_equal "Randomness.", @expense.card_expense.editable_merchant
    assert @expense.receipts.blank?
    amount = @expense.amount_value
    card_expense_op = Expense::Card::Update.new(@user, @update_expense_params)
    @expense = card_expense_op.run

    # ensuring none of the original parameters have changed
    assert_equal amount, @expense.amount_value
    assert_equal "Olacabs", @expense.card_expense.editable_merchant
    assert_not @expense.receipts.blank?
  end

  # immutable parameters: amount, currency, date
  test 'cannot update immutable parameters' do
    # checking previous card expense values
    assert_equal "Randomness.", @expense.card_expense.editable_merchant
    assert @expense.receipts.blank?

    card_expense_op = Expense::Card::Update.new(@user, @invalid_update_params)
    @expense = card_expense_op.run
    assert @expense
    assert_equal "Randomness.", @expense.card_expense.editable_merchant
    assert @expense.receipts.blank?

  end
end