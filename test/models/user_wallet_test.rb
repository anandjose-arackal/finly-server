# == Schema Information
#
# Table name: user_wallets
#
#  id         :integer          not null, primary key
#  balance_id :integer          not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class UserWalletTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
