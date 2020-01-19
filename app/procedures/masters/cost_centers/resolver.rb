class Masters::CostCenters::Resolver < Resolver::API

  entity CostCenter

  def load(params)
    user.company.cost_centers
  end

end