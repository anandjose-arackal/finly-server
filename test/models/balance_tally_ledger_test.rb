# == Schema Information
#
# Table name: balance_tally_ledgers
#
#  id                        :integer          not null, primary key
#  date                      :date
#  api_balance_id            :integer
#  finly_database_balance_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  calculated_balance_id     :integer
#

require 'test_helper'

class BalanceTallyLedgerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
