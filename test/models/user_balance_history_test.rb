# == Schema Information
#
# Table name: user_balance_histories
#
#  id                         :integer          not null, primary key
#  date                       :datetime
#  user_id                    :integer
#  company_id                 :integer
#  card_balance_id            :integer
#  card_withdrawal_id         :integer
#  card_load_id               :integer
#  card_spend_id              :integer
#  finly_money_balance_id     :integer
#  finly_money_withdrawal_id  :integer
#  finly_money_load_id        :integer
#  cash_on_hand_balance_id    :integer
#  cash_on_hand_withdrawal_id :integer
#  cash_on_hand_load_id       :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'test_helper'

class UserBalanceHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
