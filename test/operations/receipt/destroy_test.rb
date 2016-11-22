require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @employee = users(:employee)
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @receipt = Receipt::Create.(@employee, {receipt: {image: @image}}).receipt
    @other_user = users(:admin)
    @expense = Expense.first
  end

  test "destroying an existing receipt" do
    destroy_op = Receipt::Destroy.new(@employee, receipt_id: @receipt.id)
    assert_difference '@employee.receipts.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not Receipt.exists?(@receipt.id)
  end

  test "cannot delete another user's receipts" do
    # mocking the ownership of the receipt as belonging to another user
    Receipt.any_instance.stubs(:user_id).returns(@other_user.id)

    destroy_op = Receipt::Destroy.new(@employee, receipt_id: @receipt.id)
    assert_no_difference 'Receipt.all.count' do
      begin
        @result = destroy_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert Receipt.exists?(@receipt.id)
  end

  test "cannot destroy a receipt that is associated with an expense" do
    # mocking the presence of an expense associated with this receipt
    Receipt.any_instance.stubs(:parent).returns(@expense)

    destroy_op = Receipt::Destroy.new(@employee, receipt_id: @receipt.id)
    assert_no_difference 'Receipt.all.count' do
      @result = destroy_op.run
    end

    assert_not @result.success?
    assert_not @result.messages[:error].empty?
  end

end