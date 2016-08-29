# action to destroy a policy - deleting a policy will remove its association with all members.
# params:
# policy_id : policy that needs to be deleted

class Policy::Destroy < Policy::Base


  def init
    self.policy = Policy::List.(user).find_by(id: params[:policy_id])
  end

  def authorize
    unless policy
      raise_unauthorized_exception
    end
  end

  def process
    unless self.policy.destroy
      errors << "Couldn't delete policy. PLease try again."
    end
  end

  def retrieve
    if is_success?
      return true
    else
      return false
    end
  end
end