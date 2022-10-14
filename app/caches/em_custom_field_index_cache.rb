class EmCustomFieldIndexCache < BaseApplicationCache

  def initialize(current_user, params_hash)
    @params_hash = params_hash
    super(current_user)
  end

  def enabled?
    EmFieldConfigCacheToggle.new(@current_user).enabled?
  end

  def cache_instance_id
    @params_hash
  end

  def expires_in
    nil
  end
end
