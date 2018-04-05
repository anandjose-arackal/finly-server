# == Schema Information
#
# Table name: customer_accounts
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  balance_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class CustomerAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
