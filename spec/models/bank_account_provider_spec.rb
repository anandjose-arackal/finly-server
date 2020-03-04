# == Schema Information
#
# Table name: bank_account_providers
#
#  id                            :bigint           not null, primary key
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  company_id                    :integer
#  debit_account_number          :string(255)
#  bank_account_provider_type_id :integer
#  deleted_at                    :datetime
#

require 'rails_helper'

RSpec.describe BankAccountProvider, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
