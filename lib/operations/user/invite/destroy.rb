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
    id = params[:id] or params[:invited_user_id]
    self.invited_user = User.invitation_not_accepted.find_by_id(id)
  end

  def validate

  end

  def authorize
    unless invited_user.present?
      raise_unauthorized_exception
    end

    unless user.admin? or user.id == invited_user.invited_by_id
      raise_unauthorized_exception
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

  # since it's a destoy operation, return truw or false
  def retrieve
    if is_success?
      return true
    else
      return false
    end
  end
end