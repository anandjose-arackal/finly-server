require 'test_helper'

class ReceiptTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @expense_with_receipt = @user.expenses.filter_receipt('present').first
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @other_image = File.open(Rails.root + "app/assets/images/queue_details.png", "r")
    @manual_expense_params = {expense: {amount_attributes: { value: 100, currency_id: 1 },
                                        manual_expense_attributes: {merchant: "Olacabs"},
                                        note: "Sup dawg",
                                        date: DateUtils.local_date,
                                        category_id: 1
                                       }
                             }

    @new_expense = Expense::Manual::Create.(@user, @manual_expense_params).expense

    @receipt_params = {expense: {receipts_attributes: {image: @image}
                                },
                       type: 1,
                       id: @new_expense.id
                      }

    @remove_receipt_params = {expense: {receipts_attributes: ""
                                       },
                              type: 1,
                              id: @new_expense.id
                             }

    @other_user = User.second
    @other_expense = @other_user.expenses.first

    @other_receipt_params = {expense: {receipts_attributes: {image: @other_image}
                                      },
                             type: 1,
                             id: @other_expense.id
                            }

  end

  test "successfully adding a receipt to a manual expense" do

    # checking that the newly created expense doesn't have receipts attached
    assert_not @new_expense.receipts.present?
    update_op = Expense::Manual::Update.new(@user, @receipt_params)
    assert_difference '@new_expense.receipts.count', 1 do
      @result = update_op.run
    end
    assert @result.success?
    @new_expense.reload
    assert @new_expense.receipts.present?
    # assert the newly added expense belongs to the user whose expense was added
    assert_equal @user.id, @new_expense.receipts.first.user_id
  end

  test "cannot add receipt to someone else's manual expense" do
    assert_not @other_expense.receipts.present?
    update_op = Expense::Manual::Update.new(@user, @other_receipt_params)
    assert_no_difference '@other_expense.receipts.count' do
      begin
        @result = update_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
    assert_not @other_expense.receipts.present?
  end


  test "if expense already contains a receipt, it's replaced" do
    assert_not @expense_with_receipt.receipts.empty?
    old_receipt = @expense_with_receipt.receipts.first

    # resetting other receipt params to the expense with receipts, and changing the image file
    @other_receipt_params[:id] = @expense_with_receipt.id

    update_op = Expense::Manual::Update.new(@user, @other_receipt_params)
    # no difference because the receipt is getting replaced
    assert_no_difference '@expense_with_receipt.receipts.count' do
      @result = update_op.run
      old_receipt.reload
      @expense_with_receipt.reload
    end
    assert @result.success?
    assert_not @expense_with_receipt.receipts.empty?
    assert_equal "queue_details.png", @expense_with_receipt.receipts.first.image_file_name
  end

  test "successfully unassociating a receipt from an expense" do
    assert_not @expense_with_receipt.receipts.empty?

    @remove_receipt_params[:id] = @expense_with_receipt.id
    update_op = Expense::Manual::Update.new(@user, @remove_receipt_params)

    assert_difference '@expense_with_receipt.receipts.count', -1 do
      assert_difference '@user.receipts.without_parent.count', 1 do
        @result = update_op.run
      end
    end

    @expense_with_receipt.reload
    assert @expense_with_receipt.receipts.empty?
  end

  test "reporting manager can upload a receipt on behalf of the employee" do

  end

  test "manager who is not an approving manager for the user CANNOT update the receipt of an expense" do

  end

  test "admin can update any expense in the company with a receipt" do

  end

  test "admin cannot upload receipt for a user not in the company" do

  end

end