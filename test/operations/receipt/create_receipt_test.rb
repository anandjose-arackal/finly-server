require 'test_helper'

class CreateReceiptTest < ActiveSupport::TestCase

  def setup
    @employee = users(:employee)
    @admin = users(:admin)
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @receipt_params = {receipt: {image: @image}}
  end

  test "adding a new receipt to a user" do
    receipt_op = Receipt::Create.new(@employee, @receipt_params)
    assert_difference '@employee.receipts.count', 1 do
      @result = receipt_op.run
    end
    assert @result.success?
    assert_equal @result.receipt.user_id, @employee.id
  end

  test "cannot add a receipt to another user's armada" do
    receipt_op = Receipt::Create.new(@admin, @receipt_params)
    assert_no_difference '@employee.receipts.count' do
      assert_difference '@admin.receipts.count', 1 do
        @result = receipt_op.run
      end
    end
    assert @result.success?
    assert @result.receipt.user_id, @admin.id
  end

end