require 'test_helper'

class CreateTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @image = File.open(Rails.root + "app/assets/images/1363397.png", "r")
    @receipt_params = {receipt: {image: @image}}
  end

  test 'adding a new receipt to users' do
    receipt_op = Receipt::Create.new(@user, @receipt_params)
    assert_difference '@user.receipts.count', 1 do
      @receipt = receipt_op.run
    end
    assert @receipt
    assert_equal @receipt.user_id, @user.id
  end
end