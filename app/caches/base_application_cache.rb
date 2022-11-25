class BaseApplicationCache
  attr_accessor :company, :current_user

  def initialize(current_user)
    @company = ActsAsTenant.current_tenant
    @current_user = current_user

    cache_init
  end

  def enabled?
    true
  end

  def company_scoped?
    true
  end

  def user_scoped?
    false
  end

  def skip_nil?
    true
  end

  def cache_name_key
    self.class.name
  end

  def cache_instance_id
    # Override this to provide a cache identifier
  end

  def validate_access
    if company_scoped?
      if ActsAsTenant.current_tenant.nil?
        raise ApplicationCacheAccessError.new "Company scoped cache is being accessed without a current company scope"
      end
      @company = ActsAsTenant.current_tenant
    end

    if user_scoped? && @current_user.nil?
      raise ApplicationCacheAccessError.new "User scoped cache is being accessed without a current user scope"
    end

    if (!@current_user.nil?) && @current_user.company.id != @company.id
      raise ApplicationCacheAccessError.new "Cache being accessed by unauthorized user"
    end
  end

  def final_cache_key
    cache_key_tokens = []

    # Overloading this will defeat the entire purpose of this framework
    cache_key_tokens << "#{cache_name_key}"

    if company_scoped? && !@company.nil?
      cache_key_tokens << "#{@company.id}"
    end

    if user_scoped? && !@current_user.nil?
      cache_key_tokens << "#{@current_user.id}"
    end
    cache_key_tokens << cache_instance_id
    ActiveSupport::Cache.expand_cache_key cache_key_tokens
  end

  def expires_in
    if Rails.env.production?
      30.minutes
    else
      1.minute
    end
  end

  def eager_load_data
    # Fetch data from main datasource
    # Returns query set / data objects
  end

  def write(&block)
    unless enabled?
      return
    end
    value = block.call

    Rails.cache.write(@final_cache_key_const, value, expires_in: expires_in, skip_nil: skip_nil?)
  end

  def read
    Rails.cache.read(@final_cache_key_const)
  end

  def cache_init
    validate_access

    @final_cache_key_const = final_cache_key().freeze
    Rails.logger.debug "Initialized cache with key #{@final_cache_key_const}"
  end

  def invalidate
    # Do not override
    Rails.cache.delete(@final_cache_key_const)
  end

  def invalidate_instances(company_specific = true, user_specific = false)
    # Do not override
    cache_key_tokens = []

    cache_key_tokens << "#{cache_name_key}"

    if company_specific && company_scoped? && !@company.nil?
      cache_key_tokens << "#{@company.id}"
    end

    if user_specific && user_scoped? && !@current_user.nil?
      cache_key_tokens << "#{@current_user.id}"
    end

    part_key = ActiveSupport::Cache.expand_cache_key cache_key_tokens
    Rails.cache.delete_matched("#{part_key}/*")
  end
end