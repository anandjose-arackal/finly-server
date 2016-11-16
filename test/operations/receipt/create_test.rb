require 'test_helper'

class CreateTest < ActiveSupport::TestCase

  def setup
    @employee = users(:employee)
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @receipt_params = {receipt: {image: @image}}
  end

  test "adding a new receipt to a user" do
    receipt_op = Receipt::Create.new(@user, @receipt_params)
    assert_difference '@user.receipts.count', 1 do
      @receipt = receipt_op.run
    end
    assert @receipt.success?
    assert_equal @receipt.receipt.user_id, @employee.id
  end

  test "only images with the right formats can be uploaded as receipts" do

  end

  test "" do

  end


end