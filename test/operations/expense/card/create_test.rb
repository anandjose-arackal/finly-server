require 'test_helper'
require_relative '../../../../app/operations/expense/card/create'

class CreateTest < ActiveSupport::TestCase

  def setup
    @user = User.first
  end

  test 'creating a card expense from transaction details' do
    @transaction = @user.card_transactions.first
    @card = @transaction.card
    card_ex_op = Expense::Card::Create.new(@transaction, @card)
    assert_difference '@user.expenses.count', 1 do
      @expense = card_ex_op.run
    end
    assert @expense
    assert_equal @transaction.transaction_amount_value, @expense.amount_value
    assert_equal @transaction.merchant_name, @expense.card_expense.editable_merchant

    # should throw exception without the card object
    card_ex_op = Expense::Card::Create.new(@transaction, nil)
    assert_no_difference '@user.expenses.count' do
      @expense = card_ex_op.run rescue nil
    end
    assert_not @expense
  end


end