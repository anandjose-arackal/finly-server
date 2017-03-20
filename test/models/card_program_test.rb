# == Schema Information
#
# Table name: card_programs
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  create_expense                :boolean
#  receive_reimbursement         :boolean
#  personal_wallet_fund_transfer :boolean
#  spend_restrictions            :boolean
#  end_date_restrictions         :boolean
#  manager_credit                :boolean
#  manager_debit                 :boolean
#  manager_blockable             :boolean
#  manager_view_balance          :boolean
#  manager_view_eligibility      :boolean
#  manager_view_transactions     :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  non_personal_fund_transfer    :boolean
#

require 'test_helper'

class CardProgramTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
