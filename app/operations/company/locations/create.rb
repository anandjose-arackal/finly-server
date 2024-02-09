class Company::Locations::Create < Company::Locations::Base
  attr_accessor :location_parameters

  def init
    super
    self.location_parameters = location_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if ( self.company.locations.non_deleted.where(name: location_parameters[:name]).count > 0 )
      add_message :error, 'Location with the given name already present'
      return
    end
  end

  def process
    self.location = self.company.locations.build(location_parameters)

    if self.location.save
      add_message :success, "Successfully Added Company Branch"
    else
      add_message :error, self.location.errors.full_messages
    end
  end

end