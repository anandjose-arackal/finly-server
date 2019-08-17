class Admin::Implementations::Master::Locations::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.export'

  headers [
              :id,
              :name,
              :address_1,
              :gstin,
              :location_code,
              :nature_of_office,
              :destroy
          ]

  def valid_request

  end

  def input
    company.locations
  end

  def id(location)
    location.id
  end

  def name(location)
    location.name
  end

  def address_1(location)
    location.address_1
  end

  def gstin(location)
    location.gstin
  end

  def location_code(location)
    location.location_code
  end

  def nature_of_office(location)
    location.nature_of_office
  end

  def destroy(location)
    ''
  end

  def post_process
  end

end
