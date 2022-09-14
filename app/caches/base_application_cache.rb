class BaseApplicationCache
  attr_accessor :company, :current_user

  def initialize(company, current_user)
    @company = company
    @current_user = current_user

    cache_init
  end

  def self.enabled?
    true
  end

  def self.company_scoped?
    true
  end

  def self.user_scoped?
    false
  end

  def self.eager_load?
    !(self.user_scoped?)
  end

  def self.skip_nil?
    true
  end

  def cache_name_key
    self.class.name
  end

  def cache_instance_id
    # Override this to provide a cache identifier
  end

  def validate_access
    if @company.nil?
      if ActsAsTenant.current_tenant.nil?
        raise ApplicationCacheAccessError.new "Company scoped cache is being accessed without a current company scope"
      end
      @company = ActsAsTenant.current_tenant
    end

    if self.user_scoped? and @current_user.nil?
      raise ApplicationCacheAccessError.new "User scoped cache is being accessed without a current user scope"
    end
  end

  def final_cache_key
    # Overloading this will defeat the entire purpose of this framework
    final_key = "#{cache_name_key}"

    if self.company_scoped? and !@company.nil?
      final_key << "#{@company.id}#"
    end

    if self.user_scoped? and !@current_user.nil?
      final_key << "#{@current_user.id}#"
    end

    final_key << cache_instance_id
    final_key
  end

  def self.expires_in
    if Rails.env.production?
      15.minutes
    else
      1.minute
    end
  end

  def load_data
    # Fetch data from main datasource
    # Returns query set / data objects

  end

  def access
    # This is always supposed to be a lazy loaded cache access
    # In case this cache is not enabled, it should return data from main source
    # Do not override

    unless self.enabled?
      return load_data
    end

    Rails.cache.fetch(@final_cache_key_const, expires_in: self.expires_in, skip_nil: self.skip_nil?) do
      if self.company_scoped?
        ActsAsTenant.with_tenant(@company) do
          load_data
        end
      else
        load_data
      end
    end
  end

  def cache_init
    validate_access

    if self.eager_load? and self.user_scoped?
      raise ApplicationCacheAccessError.new "User scoped caches cannot be eager loaded"
    end

    @final_cache_key_const = final_cache_key().freeze

    if self.eager_load?
      self.access
    end
  end

  def invalidate
    # Do not override
    Rails.cache.delete(@final_cache_key_const)
  end

  def refresh
    invalidate
    if eager_load?
      access
    end
  end

end