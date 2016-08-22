# resends the invite based on email id passed in the parameters
# params:
# email - the email id of the person to whom the invite needs to be resent

class User::Invite::Resend < User::Invite::Base

  attr_accessor :invited_user

  def pre_validate
    if user.blank? or params.blank?
      errors << "User or Params not found"
    end
  end

  def init
    self.invited_user = User.invitation_not_accepted.find_by_email(params[:email])
  end

  def validate
    unless invited_user
      errors << "User to resend invite not found."
      return false
    end

  end

  def authorize
    unless user.admin? or user.id == invited_user.invited_by
      errors << 'Only inviting users or admins can delete invites.'
      return false
    end
  end

  def process
    new_invite = User.invite!(email: params[:email]) do |new_invite|
      new_invite.skip_invitation = true
    end
    unless new_invite
      errors << "Resend failed. PLease try again!"
    end
  end

  def post_process
    # send mails for resending invite
  end
end