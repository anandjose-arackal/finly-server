class Masters::Locations::Resolver < Transactions::Resolver::Scope

  entity BranchLocation, scope: :default

  def load(params)
    if user.admin?
      user.company.locations
    else
      policies = user.policies
      policies = policies.where(application: app) if app.present?
      policy_ids = policies.pluck(:id)
      location_ids = [user.location_id]
      location_ids += PolicyLocationMapping.where(policy_id: policy_ids).pluck(:location_id)
      BranchLocation.where(id: location_ids)
    end
  end

end