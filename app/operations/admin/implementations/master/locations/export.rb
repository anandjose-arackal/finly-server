class Admin::Implementations::Master::Locations::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.export'

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

  def valid_request

  end

  def input
    company.locations
  end

  def id(location)
    location.id
  end

  def parent_id(location)
    location.parent&.name
  end

  def name(location)
    location.name
  end

  def address_1(location)
    location.address_1
  end

  def address_2(location)
    location.address_2
  end

  def city(location)
    location.city
  end

  def state(location)
    location.state&.name
  end

  def pin(location)
    location.pin
  end

  def pan(location)
    location.pan
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
