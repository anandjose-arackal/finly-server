# action to update a particular user's details.

class User::Configuration::UpdateMobileNumber < User::Configuration::UpdateDetails

  def pre_validate
    super
    if params.present? and params[:user][:mobile_number].blank?
      messages[:error] << 'Mobile number cannot be empty'
    end
  end

end