class Company::Departments::Destroy < Company::Departments::Base

  attr_accessor :department

  def init
    department_id = params[:id] || params[:department_id]
    self.department = user.company.departments.find_by id: department_id
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.department.blank?
      add_message :error, "Department not found."
      return
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