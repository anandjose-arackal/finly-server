class Masters::TaxTypes::Resolver < Masters::Vendors::Resolver

  entity TaxType

  def load(params)
    TaxType.all
  end

end