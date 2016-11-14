require 'test_helper'


class DestroyTest < ActiveSupport::TestCase

  def setup
    @user = users(:employee)
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @receipt = @user.receipts.first
    @other_user = users(:admin)
  end

  test "destroying an existing receipt" do
    destroy_op = Receipt::Destroy.new(@user, receipt_id: @receipt.id)
    assert_difference '@user.receipts.count', -1 do
      @result = destroy_op.run
    end
    assert @result
  end

  test "cannot delete another user's receipts" do
    # creating a new receipt for the other user
    create_op = Receipt::Create.new(@other_user, receipt: {image: @image})
    @other_receipt = create_op.run.receipt

    destroy_op = Receipt::Destroy.new(@user, receipt_id: @other_receipt.id)
    assert_no_difference '@other_user.receipts.count' do
      @result = destroy_op.run
    end
    assert_not @result.success?
  end

end