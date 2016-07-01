require 'test_helper'

class ReceiptServiceTest < ActiveSupport::TestCase

  def setup
    @image = File.open(Rails.root + "app/assets/images/1363397.jpg", "r")
    @receipt_params = {receipt: {image: @image}}
    @user = User.first
    @rs = ReceiptService.new(@user)
    @receipt = @user.receipts.first
  end

  test 'must create a receipt for user' do
    assert_difference '@user.receipts.count', 1 do
      receipt = @rs.create_receipt @receipt_params
      assert_equal "1363397.jpg", receipt.image_file_name
    end
  end

  test 'must destroy a receipt' do
    assert_difference '@user.receipts.count', -1 do
      result = @rs.destroy_receipt @receipt.id
      assert result
    end
  end

  test "must not create a receipt that's dangling" do

  end
end