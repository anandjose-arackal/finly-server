class Masters::Vendors::BankAccounts::Resolver < Masters::Vendors::Resolver

  entity BankAccount

  def load(params)
    vendors = super(params)
    BankAccount.where(account_owner_type: 'BankAccount').where('account_owner_id in (?)', vendors.to_sql)
  end

end