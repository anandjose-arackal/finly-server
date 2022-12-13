class Masters::Vendors::BankAccounts::Resolver < Masters::Vendors::Resolver

  entity BankAccount

  def load(params)
    vendors = super(params)
    BankAccount.where(account_owner_type: 'YesBankVendor',disabled: false).where("`bank_accounts`.`account_owner_id` IN (#{vendors.select(:id).to_sql})")
  end

end