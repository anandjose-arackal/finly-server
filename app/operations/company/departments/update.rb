class Company::Departments::Update < Company::Departments::Base

  attr_accessor :department, :department_params

  def init
    self.department_params = department_attributes
    department_id = params[:id] || params[:department_id]
    self.department = user.company.departments.find_by id: department_id
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def process
    self.department.assign_attributes(department_params)
    if department.valid?
      department.save
      add_message :success, 'Successfully updated department'
    else
      add_message :error, department.errors.full_messages
    end
  end

  def department_attributes
    params.require(:department).permit(:name, :parent_id, :department_code,{user_department_mappings_attributes: [:user_id]})
  end
end