# action to accept a particular user's invitation
# params
# invitation_token: the unique string created when this user was invited
# name:
# mobile_number:
# password:

class User::Invite::Accept < User::Invite::Base
  attr_accessor :invited_user, :accept_params

  def self.call(params)
    super(nil, params)
  end

  def initialize(user, params)
    super(nil, params)
  end

  def authorized_user_types

  end

  def pre_validate
    if params.blank?
      add_message :error, 'All fields are empty'
    end
  end

  def init
    self.accept_params = user_params
    self.accept_params[:invitation_token] = params[:invitation_token] if accept_params[:invitation_token].blank?
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

    invitation_token = param[:invitation_token]
    first_name = param[:first_name]
    maiden_name = param[:maiden_name]
    last_name = param[:last_name]
    mobile_number = param[:mobile_number]
    password = param[:password]
    password_confirmation = param[:password_confirmation]

    profile_param = param[:profile_attributes]
    date_of_birth = profile_param[:date_of_birth]
    gender = profile_param[:gender]
    address_1 = profile_param[:address_1]
    address_2  = profile_param[:address_2]
    city = profile_param[:city]
    state_id = profile_param[:state_id]
    pin_code = profile_param[:pin_code]

    return unless verify_field invitation_token, 'Invite not found'
    return unless verify_field password, 'Password cannot be blank'
    return unless verify_field password_confirmation, 'Password confirmation cannot be blank'
    return unless verify_field first_name, 'First name cannot be blank'
    return unless verify_field last_name, 'Last name cannot be blank'
    return unless verify_field mobile_number, 'Mobile number cannot be blank'
    return unless verify_field date_of_birth, 'Date of birth cannot be blank'
    return unless verify_field gender, 'Gender cannot be blank'
    return unless verify_field address_1, 'Address 1 cannot be blank'
    return unless verify_field address_2, 'Address 2 cannot be blank'
    return unless verify_field city, 'City cannot be blank'
    return unless verify_field state_id, 'State ID cannot be blank'
    return unless verify_field pin_code, 'Pincode cannot be blank'
  
    if mobile_number.blank? or mobile_number.length != 10
      add_message :error, 'Mobile number has to be 10 digits'
      return
    end
    unless password == password_confirmation
      add_message :error, 'Confirmation password is not matching the given password'
    end
    # manually adding here because devise isn't throwing an error during sign up. todo - investigate
    if password.length < 8
      add_message :error, 'Password length must be at least 8 characters'
    end

    if State.name_for(state_id).blank?
      add_message :error, 'Invalid state selected'
    end

    if (pin_code =~ Constants::VALID_PIN_CODE).nil?
      add_message :error, 'Invalid Pincode entered'
    end

    unless gender == 'm' or gender == 'f'
      add_message :error, 'Invalid gender selected'
    end

    y, m, d = date_of_birth.split '-'
    unless Date.valid_date? y.to_i, m.to_i, d.to_i
      add_message :error, 'Invalid date provided'
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

  def process
    self.invited_user = User.accept_invitation!(accept_params)
    unless invited_user.present? and invited_user.id.present?
      add_message :error, invited_user.errors.full_messages
    end
  end

  def post_process
    # send welcome mail

    # Send OTP Verification
    User::Verification::Otp::Create.(invited_user, params)
  end

  def success
    User::Invite::Base::InvitePresenter.new(user, {accepted_user: invited_user}, messages)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation, :invitation_token, :mobile_number, :first_name,
                                 :maiden_name, :last_name,
                                 profile_attributes: [:date_of_birth, :gender, :address_1,
                                                      :address_2, :city, :state_id, :pin_code])
  end


end