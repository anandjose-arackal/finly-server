# == Schema Information
#
# Table name: bank_account_providers
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class BankAccountProvider < NonTenantedApplicationRecord
  # include Seedable

  def self.values
    [
        :yes_bank, :icici_bank, :kotak_mahindra_bank
    ]
  end
end
