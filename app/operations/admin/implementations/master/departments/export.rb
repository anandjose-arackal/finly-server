class Admin::Implementations::Master::Departments::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'departments.export'

  headers [
              :id,
              :parent_id,
              :name,
              :department_code
          ]

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
    department.parent&.id || ''
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
