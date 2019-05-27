class Company::Locations::BulkDestroy < Company::Locations::Base
  attr_accessor :locations

  def init
    location_ids = params[:ids] || params[:location_ids]
    self.locations = user.company.locations.where id: location_ids
  end


  def process
    # if self.locations.delete_all
    if self.locations.destroy_all
      add_message :success, 'Successfully Removed Multiple Locations'
    else
      add_message :error, "Couldn't remove multiple locations"
    end
  end

end
