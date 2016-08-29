# updating a user's configuration within the company. If no policy is passed, it updates the default team configuration.
# params:
# policy_id: if the configuration update is for a particular policy



class UpdateConfiguration < User::Team::Base

  attr_accessor :policy

  def authorized_user_types
    [:admin, :policy_admin]
  end

  def init
    self.policy = Policy::List.(user, view: params[:view])
  end
end