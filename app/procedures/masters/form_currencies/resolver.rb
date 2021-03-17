class Masters::FormCurrencies::Resolver < Masters::Vendors::Resolver

  entity FormCurrency

  def load(params)
    user.company.form_currencies.non_deleted
  end

end