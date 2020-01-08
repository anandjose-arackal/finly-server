class Admin::Implementations::Master::Departments::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'departments.export'

  headers({
      :id => "ID",
      :parent_id =>  "Parent Department NAME",
      :name => "Departmet Name",
      :department_code => "Department Code",
      :destroy => "Destroy"
  })

  def valid_request

  end

  def input
    company.departments
  end

  def id(department)
    department.id
  end

  def name(department)
    department.name
  end

  def parent_id(department)
    department.parent&.name || ''
  end

  def department_code(department)
    department.department_code
  end

  def destroy(department)
    ''
  end

  def post_process
  end

end
