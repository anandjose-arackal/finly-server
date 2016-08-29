# the invite to be destroyed is determined by the invited_user_id passed in the params
# params:
# invited_user_id: id of the user who has been invited and needs to now be destroyed

class User::Invite::Destroy < User::Invite::Base

  attr_accessor :invited_user

  def pre_validate
    if user.blank? or params.blank?
      errors << "User or params not found."
    end
  end

  def init
    self.invited_user = User.invitation_not_accepted.find_by_id(params[:invited_user_id])
  end

  def validate
    unless invited_user.present?
      errors << "Invite not found!"
    end
  end

  def authorize
    unless user.admin? or user.id == invited_user.invited_by
      errors << 'Only inviting users or admins can delete invites.'
      return false
    end
  end

  def process
    unless invited_user.destroy
      errors << "Invite couldn't be deleted. Please try again."
      return false
    end
  end

  def post_process
    # probably nothing right now.
  end
end