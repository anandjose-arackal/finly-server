class Admin::Implementations::Master::Locations::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'locations.import_template'
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
    []
  end

  def post_process
  end

end
