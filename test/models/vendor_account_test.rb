# == Schema Information
#
# Table name: vendor_accounts
#
#  id                 :integer          not null, primary key
#  yes_bank_vendor_id :integer
#  account_number     :string(255)
#  ifsc               :string(255)
#  name               :string(255)
#  address_1          :string(255)
#  address_2          :string(255)
#  address_3          :string(255)
#  pin_code           :string(255)
#  country            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class VendorAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
