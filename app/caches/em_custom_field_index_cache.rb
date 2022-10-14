class EmCustomFieldIndexCache < BaseApplicationCache
  def enabled?
    EmFieldConfigCacheToggle.new(@current_user).enabled?
  end

  def cache_instance_id
    "ONLY"
  end

  def expires_in
    nil
  end
end
