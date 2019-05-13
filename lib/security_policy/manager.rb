class SecurityPolicy::Manager
  attr_accessor :user, :user_roles, :user_role_names

  ENFORCERS = {
      browser: SecurityPolicy::Enforcers::Browser,
      gatekeeper: SecurityPolicy::Enforcers::Gatekeeper,
      password: SecurityPolicy::Enforcers::Password,
  }

  ENFORCERS.each do |key, klass|
    attr_accessor key
  end

  def self.for(user)
    if RequestStoreUtil.security_policy&.user == user
      return RequestStoreUtil.security_policy
    end
    SecurityPolicy::Manager.new(user)
  end

  def initialize(user)
    self.user = user
    self.user_roles = user.user_roles
    self.user_role_names = user.user_roles.pluck(:name)
    init_config
  end

  def init_config
    ENFORCERS.each do |key, klass|
      self.send("#{key}=", klass.new(user, user_roles, user_role_names))
    end
  end

end