class Company::Departments::Index < Company::Departments::Base

  attr_accessor :departments, :policy_department_filter_mapping

  class Company::Departments::Index::DepartmentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :departments, :company_departments, :policy_department_filter_mapping, :policy_user_department_document_mapping


    def init
      self.departments = params[:departments]
      # Company departments has all the departments beloging to that company
      self.departments = self.departments.filter_only_roots
      self.company_departments =  params[:departments]
      self.policy_department_filter_mapping = params[:policy_department_filter_mapping]
    end
  end


  def process
    if user.company_admin? || user.vp_admin_or_auditor?
      self.departments = self.company.departments
    else
      self.departments = user.departments
    end
    user_role_id = params[:filter_role_id]
    if user_role_id.present?
      department_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ? AND policy_user_roles.user_role_id = ?', user.id, user_role_id).joins(:policy_department_mappings).with_application(current_app).exclude_deleted.pluck('policy_department_mappings.department_id')
    else
      # User has any role in policy
      department_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_id = ?', user.id).joins(:policy_department_mappings).with_application(current_app).exclude_deleted.pluck('policy_department_mappings.department_id')
    end
    department_parent_id = [user.company.departments.where(id: department_ids)&.last&.parent&.id] rescue []
    # To be shown on filter page
    self.policy_department_filter_mapping = user.company.departments.where(id: department_ids + department_parent_id) unless department_ids.blank?

  end

  def success
    params[:departments] = self.departments
    params[:policy_department_filter_mapping] = self.policy_department_filter_mapping
    Company::Departments::Index::DepartmentsPresenter.new(user, params, messages)
  end
end