class Docs::Trips::Resolver < Resolver::API

  entity Trip

  def load(params)
    if ViewHelper.admin?(params) and user.admin?
      # Admin
      user.company.trips.non_draft
    elsif ViewHelper.team?(params)
      # Team
      # policies = user.policies
      # policies = policies.where(application: app) if app.present?
      # policy_ids = policies.pluck(:id)
      # trip_ids = [user.department_id]
      # department_ids += PolicyDepartmentMapping.where(policy_id: policy_ids).pluck(:department_id)
      # Department.where(id: department_ids)
    else
      # Personal
      user.trips
    end
  end

end