class EmCustomFieldShowCache < BaseApplicationCache
  def initialize(current_user, id)
    @id = id
    super current_user
  end

  def enabled?
    EmFieldConfigCacheToggle.new(@current_user).enabled?
  end

  def cache_instance_id
    @id
  end

  def expires_in
    nil
  end
end
