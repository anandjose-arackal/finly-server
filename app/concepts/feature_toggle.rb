class FeatureToggle

  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def cache_expires_in
    if Rails.env.production?
      15.minutes
    else
      1.minute
    end
  end

  def cache_key
    "feature_flag/user##{user.id}"
  end

  # This caches the flag for a period of 1 hour
  def flags
    @flags ||= Rails.cache.fetch(cache_key, expires_in: cache_expires_in) do
      Rails.configuration.bullet_train&.get_flags(user.analytics_id)&.with_indifferent_access rescue nil
    end
  end

  def clear_cache
    Rails.cache.delete(cache_key)
  end

  def enabled?(feature, default = false) 
    return default if flags.nil?

    flag = flags[normalize_key(feature)]
    return default if flag.nil?

    flag[:enabled]
  end

  def value(key, default = nil)
    flag = flags[normalize_key(key)]
    return default if flag.nil?

    flag[:value]
  end

  def incr_counter(trait)
    Rails.configuration.bullet_train&.incr_counter user.analytics_id, trait
  end

  def set_trait(trait, value)
    Rails.configuration.bullet_train&.set_trait user.analytics_id, trait, value
  end

  def set_traits(properties)
    Rails.configuration.bullet_train&.set_traits user.analytics_id, properties
  end

  def normalize_key(key)
    key.to_s.downcase
  end

end