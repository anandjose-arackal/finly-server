class SecurityPolicy::Manager
  include EventBus::Bus

  subscribers_path "#{Rails.root}/lib/security_policy/enforcers"

  attr_accessor :user, :user_roles, :user_role_names

  def self.for(user)
    if RequestStoreUtil.security_policy&.user == user
      return RequestStoreUtil.security_policy
    end
    SecurityPolicy::Manager.new(user)
  end

  def initialize(user)
    self.user = user
    # Consider roles across all user objects in-case of group entity structure
    self.user_role_names = UserRole.with_id(user.associated_group_role_ids).pluck(:name)
    self.user_role_names = user_role_names.map { |role| role.gsub(" ", "_").underscore }
    user_role_names.uniq!
    self.user_role_names << 'employee' if self.user_role_names.blank?
    init_config
  end

  def init_config
    SecurityPolicy::Manager.subscribers.each do |key, klass|
      self.class.send(:attr_accessor, key) unless self.respond_to?(key)

      self.send("#{key}=", klass&.first.new(user, user_roles, user_role_names))
    end
  end

end