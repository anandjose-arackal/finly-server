class Company::Departments::Index < Company::Departments::Base

  attr_accessor :departments

  class Company::Locations::Index::DepartmentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :departments


    def init
      self.departments = params[:departments]
      self.departments = self.departments.filter_only_roots
    end
  end


  def process
    if user.company_admin? || user.vendor_payment_admin?
      self.departments = self.company.departments
    else
      self.departments = user.departments
    end
  end

  def success
    params[:departments] = self.departments
    Company::Locations::Index::DepartmentsPresenter.new(user, params, messages)
  end
end