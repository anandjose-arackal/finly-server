class Masters::Departments::Resolver < Resolver::API

  entity Department

  def load(params)
    if params.dig(:assignments, :form) == true
      doc_user = params[:document_type]&.classify&.constantize.find(params[:document_id]).created_by rescue user
      departments = Company::Departments::Index.(doc_user, params).policy_department_filter_mapping
      departments
    else
      if user.admin?
        user.company.departments
      else
        policies = user.policies
        policies = policies.with_application(app) if app.present?
        policy_ids = policies.pluck(:id)
        department_ids = [user.department_id]
        department_ids += PolicyDepartmentMapping.where(policy_id: policy_ids).pluck(:department_id)
        Department.where(id: department_ids)
      end
    end
  end

end