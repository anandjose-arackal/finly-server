class FeatureToggle

  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def flags
    @flags ||= BULLET_TRAIN&.get_flags(user.id)
  end

  def enabled?(feature, default = false)
    flag = flags[normalize_key(feature)]
    return default if flag.nil?

    flag[:enabled]
  end

  def value(key, default = nil)
    flag = flags[normalize_key(key)]
    return default if flag.nil?

    flag[:value]
  end

  def set_trait(trait, value)
    BULLET_TRAIN&.set_trait user.id, trait, value
  end

  def normalize_key(key)
    key.to_s.downcase
  end

end