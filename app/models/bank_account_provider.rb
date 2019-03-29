# == Schema Information
#
# Table name: bank_account_providers
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BankAccountProvider < ApplicationRecord
  include Seedable

  def self.values
    [
        :yes_bank, :icici_bank, :kotak_mahindra_bank
    ]
  end
end
