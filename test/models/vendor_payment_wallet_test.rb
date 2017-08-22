# == Schema Information
#
# Table name: vendor_payment_wallets
#
#  id         :integer          not null, primary key
#  balance_id :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class VendorPaymentWalletTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
