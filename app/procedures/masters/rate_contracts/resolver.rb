class Masters::RateContracts::Resolver < Resolver::API

  entity RateContract

  def load(params)
    user.company.rate_contracts
  end

end