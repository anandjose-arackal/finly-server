class Company::Locations::Exports::Base < ::Company::Locations::Base
  attr_accessor  :headers, :locations

  def init
    self.locations = user.company.locations.includes(:state)
    self.headers = default_headers
  end

  class Company::Locations::Exports::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:export_name]
    end

  end

  private

  def default_headers
    [
        "Location",
        "Location Code",
        "Address",
        "City",
        "PIN",
        "State",
        "PAN",
        "GSTIN",
        "Nature of Office"
    ]
  end


  def retrieve_data(location)
    data_arr = []
    data_arr << location.name
    data_arr << location.location_code
    data_arr << "#{location.address_1} #{location.address_2}"
    data_arr << location.city
    data_arr << location.pin
    data_arr << location&.state&.name
    data_arr << location.pan
    data_arr << location.gstin
    data_arr << location.nature_of_office
    data_arr
  end
end
