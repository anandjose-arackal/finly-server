class Admin::Implementations::Master::Locations::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.import'
  headers ({
      :id => "ID",
      :parent_id => "Parent Location Name",
      :name => "Name",
      :address_1 => "Address Line1",
      :address_2 => "Address Line2",
      :city => "City",
      :state => "State",
      :pin => "PIN",
      :pan => "PAN",
      :gstin => "GSTIN",
      :location_code => "Location Code",
      :nature_of_office => "Nature of Office",
      :destroy => "Destroy"
  })

  def create_record(data)
    data, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    location = self.company.locations.build data.except(:id,:destroy,:state)
    unless location.save
      return result false, location.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    data, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    location = self.company.locations.find_by id: data[:id]
    unless location
      return result false, "Location not found"
    end

    unless location.update(data.except(:destroy,:state))
      return result false, location.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
   location = self.company.locations.find_by id: data[:id]
   unless location
    return result false, "Location not found"
   end
   unless location.destroy
     return result false, location.errors.full_messages
   end
   result true, "Destroyed Successfully"
  end

  def set_params(data)
    messages = []
    state_id = nil
    if data[:state].present?
      state_id = State.where('name LIKE ?', "%#{data[:state]}%")&.first&.id
      data[:state_id] = state_id
      unless state_id.present?
        messages << "State name is incorrect"
      end
    end
    if data[:name].blank?
      messages << "Name cant be blank"
    end
    parent_name= data[:parent_id]&.to_s

    if parent_name.present?
      parent = company.locations.find_by_name(parent_name)&.id
      data[:parent_id] = parent&.to_s if parent.present?
      messages <<  "Parent Location Not found" if parent.blank?
    end

    [data, messages]
  end

end
