class Masters::Departments::Resolver < Transactions::Resolver::Scope

  entity Department, scope: :default

  def resolve(user, params)
    if user.admin?
      Success(user.company.departments)
    else
      policies = user.policies
      policies = policies.where(application: app) if app.present?
      policy_ids = policies.pluck(:id)
      department_ids = [user.department_id]
      department_ids += PolicyDepartmentMapping.where(policy_id: policy_ids).pluck(:department_id)
      Success(Department.where(id: department_ids))
    end
  end

end