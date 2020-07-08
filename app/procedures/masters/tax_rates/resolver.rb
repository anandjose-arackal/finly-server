class Masters::TaxRates::Resolver < Masters::Vendors::Resolver

  entity TaxRate

  def load(params)
    user.company.tax_rates
  end

end