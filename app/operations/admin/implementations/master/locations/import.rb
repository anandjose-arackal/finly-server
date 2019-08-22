class Admin::Implementations::Master::Locations::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.import'
  headers [
              :id,
              :name,
              :address_1,
              :address_2,
              :city,
              :state,
              :pin,
              :pan,
              :gstin,
              :location_code,
              :nature_of_office,
              :destroy
          ]
  def create_record(data)
    data, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    location = self.company.locations.new data.except(:id,:destroy,:state)
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
        messages << "Unable to match state name"
      end
    end
    if data[:name].blank?
      messages << "Name cant be blank"
    end
    [data, messages]
  end

end
