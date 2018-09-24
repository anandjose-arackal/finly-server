class Company::Departments::Show < Company::Departments::Base

  attr_accessor :department

  def init
    department_id = params[:id] || params[:department_id]
    self.department = user.company.departments.find_by id: department_id
  end

  def success
    params[:department] = self.department
    Company::Departments::Show::ShowPresenter.new(user, params, messages)
  end

  class Company::Departments::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :department, :sub_departments, :users, :parent_department, :actions

    def init
      self.department = params[:department]
      self.parent_department = self.department.parent
      self.sub_departments = self.department.children
      user_ids = self.department.users.pluck(:id)
      self.sub_departments.each do |sub_dept|
        user_ids += sub_dept.users.pluck(:id)
      end

      self.users = user.company.users.with_id(user_ids.uniq)


      self.actions = {
          create_department: get_create_department
      }
    end

    def get_create_department
      parent_department.blank?
    end
  end
end