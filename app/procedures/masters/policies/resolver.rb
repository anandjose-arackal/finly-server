class Masters::Policies::Resolver < Resolver::API

  entity Policy

  def load(params)
    return user.company.policies if user.admin?

    user.policies
  end

end