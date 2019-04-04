class Company::Departments::Index < Company::Departments::Base

  attr_accessor :departments

  class Company::Departments::Index::DepartmentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :departments, :company_departments


    def init
      self.departments = params[:departments]
      # Company departments has all the departments beloging to that company
      self.departments = self.departments.filter_only_roots
      self.company_departments =  params[:departments]
    end
  end


  def process
    if user.company_admin? || user.vp_admin_or_auditor?
      self.departments = self.company.departments
    else
      self.departments = user.departments
    end
  end

  def success
    params[:departments] = self.departments
    Company::Departments::Index::DepartmentsPresenter.new(user, params, messages)
  end
end