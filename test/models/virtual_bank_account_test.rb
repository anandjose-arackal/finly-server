# == Schema Information
#
# Table name: virtual_bank_accounts
#
#  id                        :integer          not null, primary key
#  account_number            :string(255)
#  ifsc                      :string(255)
#  description               :text(65535)
#  parent_id                 :integer
#  parent_type               :string(255)
#  company_id                :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  expires_by                :date
#  purpose_id                :integer
#  active                    :boolean          default(TRUE)
#  is_deleted                :boolean          default(FALSE)
#  initiating_user_id        :integer
#  name                      :string(255)
#  receiving_account_id      :integer
#  receiving_account_type    :string(255)
#  maximum_amount_id         :integer
#  minimum_amount_id         :integer
#  allowed_transaction_count :integer
#  neft                      :boolean          default(TRUE)
#  imps                      :boolean          default(TRUE)
#  rtgs                      :boolean          default(TRUE)
#  current_account           :boolean          default(TRUE)
#  savings_account           :boolean          default(TRUE)
#  upi                       :boolean          default(TRUE)
#  date_after                :date
#  date_on                   :date
#

require 'test_helper'

class VirtualBankAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
