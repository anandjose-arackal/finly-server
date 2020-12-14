class BankAccountExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :account_owner, record_attribute: true, exposure: true, includes: [:account_owner]
  attribute :account_number, record_attribute: true
  attribute :ifsc, record_attribute: true
  attribute :name, record_attribute: true
  attribute :verified, record_attribute: :yes_bank_verified
  attribute :default_account, record_attribute: true

end