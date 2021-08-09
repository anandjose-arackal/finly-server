class Masters::Countries::Resolver < Masters::Vendors::Resolver

  entity Country

  def load(params)
    Country.all
  end

end