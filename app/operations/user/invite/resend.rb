# resends the invite based on email id passed in the parameters
# params:
# email - the email id of the person to whom the invite needs to be resent

class User::Invite::Resend < User::Invite::Base

  attr_accessor :invited_user

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'User or Params not found'
    end
  end

  def init
    id = (params[:id] or params[:invite_id])
    email = (params[:email] or params[:invite_email])
    if id
      self.invited_user = User.invitation_not_accepted.find_by_id(id)
    elsif email
      self.invited_user = User.invitation_not_accepted.find_by_email(email)
    end
  end

  def authorize
    unless user.admin? or user.id == invited_user.invited_by_id
      messages[:error] << 'Only inviting users or admins can delete invites.'
      raise_unauthorized_exception
    end
  end

  def validate
    unless invited_user
      messages[:error] << 'Invite not found'
      return
    end
    unless invited_user.invitation_sent_at.present? and invited_user.invitation_accepted_at.blank?
      messages[:error] << 'Invite cannot be resent as user has already signed up with Finly'
    end
  end

  def process
    unless invited_user.invite!
      self.messages[:error] = self.invited_user.errors.full_messages
    end
  end

  def success
    User::Invite::Base::InvitePresenter.new(user, {invite: invited_user}, messages)
  end

  def post_process
    messages[:success] << "Invite resent!"
  end

end