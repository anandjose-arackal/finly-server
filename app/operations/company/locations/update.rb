class Company::Locations::Update < Company::Locations::Base

  def init
    super
    location_id = params[:id] || params[:location_id]
    self.location = user.company.locations.find_by id: location_id


    self.location_parameters = location_params
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    unless self.location.present?
      add_message :error, "Cannnot find Location"
    end
  end

  def process
    self.location.assign_attributes(location_parameters)

    if self.location.valid?
      self.location.save
      add_message :success, "Successfully Updated Location"
    else
      add_message :error, self.location.errors.full_messages
    end
  end

end