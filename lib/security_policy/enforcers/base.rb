class SecurityPolicy::Enforcers::Base
  include EventBus::Subscriber
  attr_accessor :user, :user_roles, :user_role_names

  def initialize(user, user_roles, user_role_names)
    self.user = user
    self.user_roles = user_roles
    self.user_role_names = user_role_names
  end

end
