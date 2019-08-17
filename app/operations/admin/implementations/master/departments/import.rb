class Admin::Implementations::Master::Departments::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'departments.import'
  halt_on_failure!
  headers [
              :id,
              :parent_id,
              :name,
              :department_code
          ]
  def create_record(data)
    department = self.company.departments.new data.except(:id)
    unless department.save
      return result false, department.errors.full_messages
    end
    result true

  end

  def update_record(data)
    department = self.company.departments.find_by id: data[:id]
    unless department
      return result false, "department not found"
    end

    unless department.update(data)
      return result false, department.errors.full_messages
    end
    result true
  end
end
