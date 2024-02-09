class Company::Locations::Destroy < Company::Locations::Base

  attr_accessor :location

  def init
    location_id = params[:id] || params[:location_id]
    self.location = user.company.locations.find_by id: location_id
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.location.blank?
      add_message :error, "Location not found."
      return
    end
  end


  def process
    if self.location.destroy
      add_message :success, 'Successfully Removed location'
    else
      add_message :error, "Couldn't remove location"
    end
  end
end