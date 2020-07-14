class Masters::TdsSlabs::Resolver < Masters::Vendors::Resolver

  entity TdsRatesList

  def load(params)
    user.company.tds_slabs
  end

end