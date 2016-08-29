# action to accept a particular user's invitation
# params
# invitation_token: the unique string created when this user was invited
# name:
# mobile_number:
# password:

class User::Invite::Accept < User::Invite::Base

  attr_accessor :invited_user, :accept_params

  def initialize(params)
    self.params = params
    # self.params = (ActionController::Parameters.new(params) or {})
    self.errors = []
  end

  def authorized_user_types

  end

  def pre_validate
    if params.blank?
      errors << 'All fields are empty'
      return false
    end
  end

  def init

  end

  def validate
    invitation_token = params[:invitation_token]
    name = params[:name]
    mobile_number = params[:mobile_number]
    password = params[:password]
    if invitation_token.blank?
      errors << 'Invite not found'
      return false
    end
    if name.blank?
      errors << 'Name can\'t be blank'
      return false
    end
    if mobile_number.blank?
      errors << 'Mobile number can\'t be blank'
      return false
    end
    if password.blank?
      errors << 'Password can\'t be blank'
      return false
    end
  end

  def authorize

  end

  def process
    self.invited_user = User.accept_invitation!(params)
    unless invited_user.present? and invited_user.id.present?
      errors << invited_user.errors.full_messages
      true
    end
  end

  def post_process
    # send welcome mail
  end

end