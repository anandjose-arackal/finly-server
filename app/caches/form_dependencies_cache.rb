class FormDependenciesCache < BaseApplicationCache
  attr_accessor :params, :op_result, :op_success

  def initialize(current_user, form_route = nil, klass_name = nil, ignore_cache = false)
    if form_route.nil? && klass_name.nil?
      raise ApplicationCacheAccessError.new "FormDependenciesCache needs either form_route or klass_name"
    end

    @ignore_cache = ignore_cache

    @form_route = form_route
    if form_route.nil?
      @klass_name = klass_name
    end

    super(current_user)
  end

  def expires_in
    if Rails.env.production?
      30.minutes
    else
      15.minutes
    end
  end

  def enabled?
    SaviourCachesToggle.new(@current_user).enabled? && !(@ignore_cache)
  end

  def cache_instance_id
    if !@klass_name.nil?
      klass_name = @klass_name
    else
      klass_name = Forms::Router.klass(@form_route)&.name
    end

    "#{klass_name}"
  end

end

