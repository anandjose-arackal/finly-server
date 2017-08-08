# == Schema Information
#
# Table name: company_accounts
#
#  id                      :integer          not null, primary key
#  company_id              :integer          not null
#  wallet_balance_id       :integer
#  company                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  company_account_type_id :integer
#

require 'test_helper'

class CompanyAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
