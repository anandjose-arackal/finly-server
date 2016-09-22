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
  end

  def validate
    invitation_token = accept_params[:invitation_token]
    name = accept_params[:name]
    mobile_number = accept_params[:mobile_number]
    password = accept_params[:password]
    password_confirmation = accept_params[:password]
    if invitation_token.blank?
      messages[:error] << 'Invite not found'
      return
    end
    if name.blank?
      messages[:error] << 'Name can\'t be blank'
      return
    end
    if mobile_number.blank?
      messages[:error] << 'Mobile number can\'t be blank'
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
  end

  def success
    User::Invite::Base::InvitePresenter.new(user, {accepted_user: invited_user}, messages)
  end

end