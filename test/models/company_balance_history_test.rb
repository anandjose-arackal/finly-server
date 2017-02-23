# == Schema Information
#
# Table name: company_balance_histories
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  neft_transfer_id          :integer
#  company_balance_id        :integer
#  company_withdrawal_id     :integer
#  company_load_id           :integer
#  card_load_id              :integer
#  card_withdrawal_id        :integer
#  card_balance_id           :integer
#  card_spend_id             :integer
#  finly_money_balance_id    :integer
#  finly_money_withdrawal_id :integer
#  finly_money_load_id       :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'test_helper'

class CompanyBalanceHistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
