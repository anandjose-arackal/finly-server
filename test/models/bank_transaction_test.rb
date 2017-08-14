# == Schema Information
#
# Table name: bank_transactions
#
#  id                          :integer          not null, primary key
#  unique_request_number       :string(255)
#  transfer_type               :string(255)
#  bank_reference_number       :string(255)
#  unique_response_number      :string(255)
#  amount_id                   :integer
#  beneficiary_bank_account_id :integer
#  company_id                  :integer
#  transfer_status_id          :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  bank_response               :string(255)
#  refunded                    :boolean
#

require 'test_helper'

class BankTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
