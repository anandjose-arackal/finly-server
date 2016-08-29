class User::Invite::Accept < User::Invite::Base


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
    u = User.accept_invitation!(params)
    unless u.present? and u.id.present?
      errors << u.errors.full_messages
      true
    end
  end

  def post_process
    # send welcome mail
  end
end