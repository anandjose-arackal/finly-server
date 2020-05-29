class Masters::Vendors::BankAccounts::Lookup < Lookup::API

  resolver 'vendors.bank_accounts.default'
  search_key :name_or_account_number_or_ifsc_cont

  attribute :id, visible: false
  attribute :name
  attribute :account_number
  attribute :ifsc

end