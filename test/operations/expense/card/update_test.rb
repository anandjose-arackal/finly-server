require 'test_helper'
require_relative '../../../../app/operations/expense/ex_card/update'
require_relative '../../../../app/operations/expense/ex_card/create'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @user = users(:employee)
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    # creating a card expense first
    @expense = @user.expenses.only_card_expenses.first
    @update_expense_params = {expense: {card_expense_attributes: {editable_merchant: "Olacabs"},
                                       note: "Randomness"},
                             id: @expense.id
                            }
    @invalid_update_params = {expense: {date: Date.yesterday,
                                        amount_attributes: {value: 200, currency_id: 1},
                                        expense_status_id: 3},
                              id: @expense.id
                             }
    @other_user = users(:manager)
    @other_expense = @other_user.expenses.first
    @admin = users(:admin)
    @manager = users(:manager)
  end

  # test "successfully updating a card expense" do
  #
  #   # checking previous card expense values
  #   merchant = @expense.card_expense.editable_merchant
  #   assert @expense.receipts.blank?
  #   amount = @expense.amount_value
  #   card_expense_op = Expense::ExCard::Update.new(@user, @update_expense_params)
  #
  #   @result = card_expense_op.run
  #   assert @result.success?
  #
  #   @expense.reload
  #   # ensuring none of the original parameters have changed
  #   assert_equal amount, @expense.amount_value
  #   assert_equal merchant, @expense.card_expense.editable_merchant
  #   assert @expense.receipts.blank?
  # end
  #
  # # immutable parameters: amount, currency, date
  # test "can't edit immutable parameters of a card expense" do
  #   # checking previous card expense values
  #   assert @expense.receipts.blank?
  #   date = @expense.date
  #   amount = @expense.amount_value
  #
  #   card_expense_op = Expense::ExCard::Update.new(@user, @invalid_update_params)
  #   @result = card_expense_op.run
  #
  #   @expense.reload
  #   assert @result.success? # the operation succeeds, but the values will not be changed
  #
  #   assert_equal date, @expense.date
  #   assert_equal amount, @expense.amount_value
  #   assert @expense.receipts.blank?
  #
  # end
  #
  # test "cannot update another user's card expense" do
  #   @update_expense_params[:expense_id] = @other_expense.id
  #   card_expense_op = Expense::ExCard::Update.new(@user, @update_expense_params)
  #   begin
  #     @result = card_expense_op.run
  #   rescue
  #     @rescued = true
  #   end
  #
  #   assert @rescued
  # end

  test "reporting manager can update a user's expense" do
    # stubbing the face that Expense Index returns the expense the manager needs to edit
    expenses_index_presenter = Expense::Index::ListPresenter.new(@admin, {expenses: Expense.where(id: @expense.id)}, nil)
    Expense::Index.stubs(:call).returns(expenses_index_presenter)

    @update_expense_params[:view] = 'manager'
    update_op = Expense::ExCard::Update.new(@manager, @update_expense_params)
    assert_no_difference '@user.expenses.count' do
      @result = update_op.run
    end
    assert @result.success?
    assert_equal "Olacabs", @result.expense.merchant_name
    assert_equal "Randomness", @result.expense.note
  end

  test "manager who's not in manager view cannot edit team member's expense" do
    # stubbing the face that Expense Index returns the expense the manager needs to edit
    expenses_index_presenter = Expense::Index::ListPresenter.new(@admin, {expenses: Expense.where(id: @expense.id)}, nil)
    Expense::Index.stubs(:call).returns(expenses_index_presenter)

    # no view passed to mimic personal view
    update_op = Expense::ExCard::Update.new(@manager, @update_expense_params)
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

    @update_expense_params[:view] = 'manager'
    update_op = Expense::ExCard::Update.new(@manager, @update_expense_params)
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

    @update_expense_params[:view] = 'admin'
    update_op = Expense::ExCard::Update.new(@admin, @update_expense_params)
    assert_no_difference '@user.expenses.count' do
      @result = update_op.run
    end
    assert @result.success?
    assert_equal "Olacabs", @result.expense.merchant_name
    assert_equal "Randomness", @result.expense.note
  end

end