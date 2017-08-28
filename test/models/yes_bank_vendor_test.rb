# == Schema Information
#
# Table name: yes_bank_vendors
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  company_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  email         :string(255)
#  mobile_number :string(255)
#

require 'test_helper'

class YesBankVendorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
