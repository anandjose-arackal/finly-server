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

class BankAccountProvider < ApplicationRecord
  # include Seedable

  def self.values
    [
        :yes_bank, :icici_bank, :kotak_mahindra_bank
    ]
  end
end
