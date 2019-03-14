class Company::Locations::Base < Company::Base
  attr_accessor :location, :location_parameters, :company

  def init
    self.company = user.company
  end

  def location_params
    params.require(:location).permit(
        :id, :name, :gstin, :pan, :address_1, :address_2,
        :city, :state_id, :country, :pin, :contact_name, :contact_mobile_number, :location_code
    )
  end
end