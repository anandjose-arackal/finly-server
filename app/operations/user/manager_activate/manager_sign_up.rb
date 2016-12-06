# should accept all the details that the manager enters for the user and sends the user a One Time Password that will
# change upon first login

require 'securerandom'

class Activate::ManagerSignUp < ManagerActivate::Base

  attr_accessor :invited_user, :accept_params

  def self.call(params)
    super(nil, params)
  end

  def initialize(user, params)
    super(nil, params)
  end

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
  end

  def validate
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
    return unless verify_field gender, 'Gender cannot be blank'
    return unless verify_field address_1, 'Address 1 cannot be blank'
    return unless verify_field address_2, 'Address 2 cannot be blank'
    return unless verify_field city, 'City cannot be blank'
    return unless verify_field state_id, 'State ID cannot be blank'
    return unless verify_field pin_code, 'Pin code cannot be blank'

    # if mobile_number.blank? or mobile_number.length != 10 or (mobile_number =~ Constants::VALID_MOBILE_NUMBER).nil?
    #   add_message :error, 'Please enter a valid mobile number'
    #   return
    # end

    if State.name_for(state_id).blank?
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
    # assign a password to the user, and send him the password on mobile. Then save it as a the password to be sent
    temp_password = generate_random_string(5)
    accept_params[:password] = accept_params[:password_confirmation] = temp_password
    message = "Your temporary password is: #{temp_password}. You will be asked to change it upon signing in"
    # sending the one time password as an SMS
    WelcomeMessage::Create.(user, {mobile_number: numbers, message: message})
  end

  def process
    self.invited_user = User.accept_invitation!(accept_params)
    unless invited_user.present? and invited_user.id.present? and invited_user.valid?
      add_message :error, invited_user.errors.full_messages
    end
  end

  def post_process
    # send welcome mail

    message[:success] << "User successfully activated!"
  end

  def success
    User::Invite::Base::InvitePresenter.new(user, {accepted_user: invited_user}, messages)
  end

  def user_params
    params.require(:user).permit(:email, :mobile_number, :first_name,
                                 :maiden_name, :last_name,
                                 profile_attributes: [:date_of_birth, :gender, :address_1,
                                                      :address_2, :city, :state_id, :pin_code])
  end

  private

  def generate_random_string(length = 8)
    SecureRandom.hex(length)
  end

end