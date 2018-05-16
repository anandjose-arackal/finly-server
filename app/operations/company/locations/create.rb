class Company::Locations::Create < Company::Locations::Base


  def init
    super
    self.location_parameters = location_params
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