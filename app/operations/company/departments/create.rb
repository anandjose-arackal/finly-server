class Company::Departments::Create < Company::Departments::Base

  attr_accessor :department, :department_params

  def init
    self.department_params = department_attributes
  end

  def process
    self.department = user.company.departments.new(department_params)
    if department.valid?
      department.save
      add_message :success, 'Successfully created new department'
    else
      add_message :error, department.errors.full_messages
    end
  end

  def department_attributes
    params.require(:department).permit(:name, :parent_id, {user_department_mappings_attributes: [:user_id]})
  end
end