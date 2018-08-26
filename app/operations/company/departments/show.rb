class Company::Departments::Show < Company::Departments::Base

  attr_accessor :department

  def init
    department_id = params[:id] || params[:department_id]
    self.department = user.company.departments.find_by id: department_id
  end

  def validate
    if self.company.blank?
      add_message :error, "Company not found"
    end
  end

  def success
    params[:department] = self.department
    Company::Departments::Show::ShowPresenter.new(user, params, messages)
  end

  class Company::Departments::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :department, :sub_departments, :users

    def init
      self.department = params[:department]
      self.sub_departments = self.department.children
      self.users = self.departments.users
    end
  end
end