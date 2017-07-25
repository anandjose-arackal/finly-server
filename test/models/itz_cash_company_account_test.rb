# == Schema Information
#
# Table name: itz_cash_company_accounts
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  wallet_balance_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class ItzCashCompanyAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
