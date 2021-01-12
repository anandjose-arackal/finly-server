class Companies::Resolver < Resolver::API

  entity Company

  def load(params)
    user.company.group.companies
  end

end