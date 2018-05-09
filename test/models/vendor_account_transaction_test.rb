# == Schema Information
#
# Table name: vendor_account_transactions
#
#  id                  :integer          not null, primary key
#  vendor_account_id   :integer
#  transaction_type_id :integer
#  amount_id           :integer
#  payment_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class VendorAccountTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
