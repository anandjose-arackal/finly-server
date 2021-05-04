# == Schema Information
#
# Table name: bank_transaction_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class BankTransactionType < NonTenantedApplicationRecord

  include Seedable

  def self.values
    [:yes_bank, :outside_finly, :icici_bank]
  end
end
