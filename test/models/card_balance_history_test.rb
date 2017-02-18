# == Schema Information
#
# Table name: card_balance_histories
#
#  id         :integer          not null, primary key
#  card_id    :integer
#  amount_id  :integer
#  timestamp  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class CardBalanceHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
