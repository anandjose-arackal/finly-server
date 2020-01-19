class Masters::CostCenters::Resolver < Transactions::Resolver::Scope

  entity CostCenter, scope: :default

  def load(params)
    user.company.cost_centers
  end

end