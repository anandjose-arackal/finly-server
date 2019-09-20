class Admin::Implementations::Master::Locations::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.import_template'
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
    []
  end

  def post_process
  end

end
