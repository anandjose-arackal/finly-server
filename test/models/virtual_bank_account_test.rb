# == Schema Information
#
# Table name: virtual_bank_accounts
#
#  id                            :integer          not null, primary key
#  account_number                :string(255)
#  ifsc                          :string(255)
#  description                   :text(65535)
#  parent_id                     :integer
#  parent_type                   :string(255)
#  company_id                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  expires_by                    :date
#  purpose_id                    :integer
#  active                        :boolean          default(TRUE)
#  is_deleted                    :boolean          default(FALSE)
#  initiating_user_id            :integer
#  name                          :string(255)
#  receiving_account_id          :integer
#  receiving_account_type        :string(255)
#  maximum_transaction_amount_id :integer
#  minimum_transaction_amount_id :integer
#  allowed_transaction_count     :integer
#  neft                          :boolean          default(TRUE)
#  imps                          :boolean          default(TRUE)
#  rtgs                          :boolean          default(TRUE)
#  current_account               :boolean          default(TRUE)
#  savings_account               :boolean          default(TRUE)
#  upi                           :boolean          default(TRUE)
#  active_after                  :date
#  active_on                     :date
#  maximum_amount_id             :integer
#  exact_transaction_amount_id   :integer
#  application                   :string(255)      not null
#  customer_id                   :integer
#  default_account               :boolean
#  deleted_at                    :datetime
#

require 'test_helper'

class VirtualBankAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
