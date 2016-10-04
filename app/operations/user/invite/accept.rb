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
      messages[:error] << 'All fields are empty'
    end
  end

  def init
    self.accept_params = user_params
    self.accept_params[:invitation_token] = params[:invitation_token] if accept_params[:invitation_token].blank?
  end

  def validate
    invitation_token = accept_params[:invitation_token]
    first_name = accept_params[:first_name]
    last_name = accept_params[:last_name]
    mobile_number = accept_params[:mobile_number]
    password = accept_params[:password]
    password_confirmation = accept_params[:password_confirmation]
    date_of_birth = accept_params[:date_of_birth]

    if invitation_token.blank?
      messages[:error] << 'Invite not found'
      return
    end
    if mobile_number.blank? or mobile_number.length != 10
      messages[:error] << 'Mobile number has to be 10 digits'
      return
    end
    if password.blank?
      messages[:error] << 'Password can\'t be blank'
    end
    if password_confirmation.blank?
      messages[:error] << 'Password can\'t be blank'
    end
    unless password == password_confirmation
      messages[:error] << 'Confirmation password is not matching the given password'
    end
    # manually adding here because devise isn't throwing an error during sign up. todo - investigate
    if password.length < 8
      messages[:error] << 'Password length must be at least 8 characters'
    end
  end

  def authorize

  end

  def process
    self.invited_user = User.accept_invitation!(accept_params)
    unless invited_user.present? and invited_user.id.present?
      messages[:error] = invited_user.errors.full_messages
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