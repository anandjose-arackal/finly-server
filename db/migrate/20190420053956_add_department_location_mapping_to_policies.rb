class AddDepartmentLocationMappingToPolicies < ActiveRecord::Migration[5.2]
  def change

    Policy.all.find_each do |policy|
      policy.company.departments.find_each do |department|
        if PolicyDepartmentMapping.where(policy_id: policy.id, department_id: department.id).blank?
          PolicyDepartmentMapping.create(policy_id: policy.id, department_id: department.id, enabled: true)
        end
      end

      policy.company.locations.find_each do |location|
        if PolicyLocationMapping.where(policy_id: policy.id, location_id: location.id).blank?
          PolicyLocationMapping.create(policy_id: policy.id, location_id: location.id, enabled: true)
        end
      end
    end

  end
end
