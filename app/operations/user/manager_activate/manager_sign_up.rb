# should accept all the details that the manager enters for the user and sends the user a One Time Password that will
# change upon first login

require 'securerandom'

class User::ManagerActivate::ManagerSignUp < User::ManagerActivate::Base

  attr_accessor :invited_user, :accept_params

  def authorized_user_types
    [:manager, :company_admin]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'All fields are empty'
    end
  end

  def init
    self.accept_params = user_params
    self.invited_user = User.find_by(mobile_number: accept_params[:mobile_number])
  end

  def validate

    if invited_user.blank?
      add_message :error, "User has not been invited"
    end

    param = accept_params

    if param.blank?
      add_message :error, 'User details cannot be blank'
      return
    end

    if param[:profile_attributes].blank?
      add_message :error, 'Please fill in all the required details to complete the registration'
      return
    end

    first_name = param[:first_name]
    last_name = param[:last_name]

    profile_param = param[:profile_attributes]
    date_of_birth = profile_param[:date_of_birth]
    gender = profile_param[:gender]
    address_1 = profile_param[:address_1]
    address_2 = profile_param[:address_2]
    city = profile_param[:city]
    state_id = profile_param[:state_id]
    pin_code = profile_param[:pin_code]

    return unless verify_field first_name, 'First name cannot be blank'
    return unless verify_field last_name, 'Last name cannot be blank'
    return unless verify_field date_of_birth, 'Date of birth cannot be blank'
    return unless verify_field gender, 'Gender not selected'
    return unless verify_field address_1, 'Address 1 cannot be blank'
    return unless verify_field address_2, 'Address 2 cannot be blank'
    return unless verify_field city, 'City cannot be blank'
    return unless verify_field state_id, 'State ID cannot be blank'
    return unless verify_field pin_code, 'Pin code cannot be blank'

    # if mobile_number.blank? or mobile_number.length != 10 or (mobile_number =~ Constants::VALID_MOBILE_NUMBER).nil?
    #   add_message :error, 'Please enter a valid mobile number'
    #   return
    # end

    if State.with_id(state_id).first.blank?
      add_message :error, 'Invalid state selected'
      return
    end

    if (pin_code =~ Constants::VALID_PIN_CODE).nil?
      add_message :error, 'Invalid Pincode entered'
      return
    end

    unless gender == 'm' or gender == 'f'
      add_message :error, 'Invalid gender selected'
      return
    end

    unless DateUtils.validate_date_format?(date_of_birth)
      add_message :error, 'Invalid date provided'
      return
    end

  end

  def verify_field(field, message)
    if field.blank?
      add_message :error, message
      return false
    end
    true
  end

  def authorize

  end

  def pre_process
    # set a dummy password here which will get replaced on first sign up
    temp_password = generate_random_string(4)
    accept_params[:password] = accept_params[:password_confirmation] = temp_password
    accept_params[:default_password] = true
  end


  def process
    unless invited_user.update_attributes(accept_params)
      add_message :error, invited_user.errors.full_messages
      return false
    end
    unless invited_user.present? and invited_user.id.present? and invited_user.valid?
      add_message :error, invited_user.errors.full_messages
    end
    invited_user.accept_invitation!
    invited_user.confirm
    invited_user.update_attributes(mobile_only_invite: false)
    # activating the user's card
    if invited_user.cards.present?
      invited_user.cards.first.update_attributes(active: true)
    end
  end

  def post_process
    # send welcome message
    message = "Your account has been successfully activated. Please go to www.finly.io to login"
    # sending the welcome message as an SMS. Mobile number is to be sent as an array of mobile numbers
    WelcomeMessage::Create.(user, {mobile_number: [invited_user.mobile_number], message: message})

    messages[:success] << "User successfully activated!"
  end

  def success
    User::Invite::Base::InvitePresenter.new(user, {accepted_user: invited_user}, messages)
  end

  def user_params
    params.require(:user).permit(:email, :mobile_number, :first_name,
                                 :last_name, :mothers_maiden_name,
                                 profile_attributes: [:date_of_birth, :gender, :address_1,
                                                      :address_2, :city, :state_id, :pin_code])
  end

  private

  def generate_random_string(length = 5)
    SecureRandom.hex(length)
  end

end
