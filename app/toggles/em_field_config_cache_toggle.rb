class EmFieldConfigCacheToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/em_field_config_cache', false
  end
end
