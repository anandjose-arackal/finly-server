# == Schema Information
#
# Table name: yes_bank_company_accounts
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  wallet_balance_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  balance_id        :integer
#

require 'test_helper'

class YesBankCompanyAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
