class SecurityPolicy::Manager
  include EventBus::Bus

  subscribers_path "#{Rails.root}/lib/security_policy/enforcers"

  attr_accessor :user, :user_roles, :user_role_names

  SecurityPolicy::Manager.subscribers.each do |key, klass|
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
    self.user_role_names << 'employee' if self.user_role_names.blank?
    init_config
  end

  def init_config
    SecurityPolicy::Manager.subscribers.each do |key, klass|
      self.send("#{key}=", klass&.first.new(user, user_roles, user_role_names))
    end
  end

end