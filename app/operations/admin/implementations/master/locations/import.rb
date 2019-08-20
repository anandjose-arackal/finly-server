class Admin::Implementations::Master::Locations::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.import'
  headers [
              :id,
              :name,
              :address_1,
              :gstin,
              :location_code,
              :nature_of_office,
              :destroy
          ]
  def create_record(data)
    location = self.company.locations.new data.except(:id,:destroy)
    unless location.save
      return result false, location.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    location = self.company.locations.find_by id: data[:id]
    unless location
      return result false, "Location not found"
    end

    unless location.update(data.except(:destroy))
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
end
