class Masters::Vendors::BankAccounts::Resolver < Masters::Vendors::Resolver

  entity BankAccount

  def load(params)
    vendors = super(params)

    # todo: confirm if more than 1 is a valid usecase
    if vendors.count > 10
      vendors = vendors.first(10)
    end
    BankAccount.where(account_owner_type: 'YesBankVendor',disabled: false).where("`bank_accounts`.`account_owner_id` IN (#{vendors.pluck(:id).join(',')})")
  end

end