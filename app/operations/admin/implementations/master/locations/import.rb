class Admin::Implementations::Master::Locations::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.import'
  halt_on_failure!
  headers [
              :id,
              :name,
              :address_1,
              :gstin,
              :location_code,
              :nature_of_office
          ]
  def create_record(data)
    location = self.company.locations.new data.except(:id)
    unless location.save
      return result false, location.errors.full_messages
    end
    result true
  end

  def update_record(data)
    location = self.company.locations.find_by id: data[:id]
    unless location
      return result false, "Location not found"
    end

    unless location.update(data)
      return result false, location.errors.full_messages
    end
    result true
  end
end
