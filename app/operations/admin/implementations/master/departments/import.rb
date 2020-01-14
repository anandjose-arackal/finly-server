class Admin::Implementations::Master::Departments::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'departments.import'

  headers(
      {
          :id => "ID",
          :parent_id => "Parent Department NAME",
          :name => "Department Name",
          :department_code => "Department Code",
          :destroy => "Destroy"
      }
  )

  def create_record(data)
    if data[:parent_id].present?
      parent_department = company.departments.non_deleted.with_name(data[:parent_id]).first
      unless parent_department.present?
        return result false, "Parent Department Not Found"
      end
    end

    if data[:name].present?
      data[:department_code] = nil if data[:department_code].blank?
      sub_department = company.departments.non_deleted.with_name(data[:name]).first
      return result false, "Department already existed" if sub_department.present?
    else
      return result false, "Department Name Missing"
    end

    sub_department = company.departments.new data.except(:id, :parent_id, :destroy)
    sub_department.parent_id = parent_department&.id rescue nil

    if sub_department.save
      return result true, "Department Created Successfully"
    else
      return result false, sub_department.errors.full_messages
    end
  end

  def update_record(data)
    department = self.company.departments.find_by id: data[:id]
    unless department
      return result false, "Department not found"
    end

    if data[:parent_id].present?
      parent_department = company.departments.non_deleted.with_name(data[:parent_id]).first
      unless parent_department.present?
        return result false, "Parent Department Not Found"
      end
      data[:parent_id] = parent_department&.id rescue nil
    end

    unless department.update(data.except(:destroy))
      return result false, department.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
    departments = self.company.departments.find_by id: data[:id]
    unless departments
      return result false, "Department not found"
    end
    unless departments.destroy
      return result false, departments.errors.full_messages
    end
    result true, "Destroyed Successfully"
  end
end
