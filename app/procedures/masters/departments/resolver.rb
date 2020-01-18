class Masters::Departments::Resolver < Transactions::Resolver::Scope

  entity Department, scope: :default

  def load(params)
    if user.admin?
      user.company.departments
    else
      policies = user.policies
      policies = policies.where(application: app) if app.present?
      policy_ids = policies.pluck(:id)
      department_ids = [user.department_id]
      department_ids += PolicyDepartmentMapping.where(policy_id: policy_ids).pluck(:department_id)
      Department.where(id: department_ids)
    end
  end

end