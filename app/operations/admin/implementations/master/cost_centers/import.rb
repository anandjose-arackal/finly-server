class Admin::Implementations::Master::CostCenters::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'cost_centers.import'
  headers ({
      :id => "ID",
      :parent_id => "Parent Cost Center Name",
      :name => "Cost Center",
      :cost_center_code => "Cost Center Code",
      :destroy => "Destroy"
  })

  attr_accessor :cost_center_params

  def create_record(data)
    cost_center_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end
    cost_center = self.company.cost_centers.build cost_center_params

    unless cost_center.save
      return result false, cost_center.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    cost_center_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end

    cost_center = self.company.cost_centers.find_by id: data[:id]
    unless cost_center
      return result false, "Cost Center not found"
    end
    unless cost_center.update(cost_center_params)
      return result false, cost_center.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
   cost_center = self.company.cost_centers.find_by id: data[:id]
   unless cost_center
    return result false, "Cost Center not found"
   end
   unless cost_center.destroy
     return result false, cost_center.errors.full_messages
   end
   result true, "Destroyed Successfully"
  end

  def set_params(data)
    messages = []
    parent_name= data[:parent_id]&.to_s

    if parent_name.present?
      parent = company.cost_centers.find_by_name(parent_name)&.id
      messages <<  "Parent Cost Center Not found" if parent.blank?
    end

    name = data[:name].to_s
    if name.blank?
      messages << "Name cant be blank"
    end

    cost_center_code = data[:cost_center_code].blank? ? nil : data[:cost_center_code]
    application = 'vp'
    ancestry = parent&.to_s

    params = {
        name: name,
        cost_center_code: cost_center_code,
        application: application,
        parent_id: ancestry
    }
    [params,messages]
  end
end
