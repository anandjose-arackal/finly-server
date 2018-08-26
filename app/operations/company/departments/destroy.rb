class Company::Departments::Destroy < Company::Departments::Base

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

  def process
    if self.department.destroy
      add_message :success, 'Successfully Removed Department'
    else
      add_message :error, "Couldn't remove department"
    end
  end
end