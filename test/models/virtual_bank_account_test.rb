# == Schema Information
#
# Table name: virtual_bank_accounts
#
#  id                     :integer          not null, primary key
#  account_number         :string(255)
#  ifsc                   :string(255)
#  description            :text(65535)
#  parent_id              :integer
#  parent_type            :string(255)
#  company_id             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  expires_by             :date
#  purpose_id             :integer
#  active                 :boolean          default(TRUE)
#  is_deleted             :boolean          default(FALSE)
#  initiating_user_id     :integer
#  name                   :string(255)
#  receiving_account_id   :integer
#  receiving_account_type :string(255)
#

require 'test_helper'

class VirtualBankAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
