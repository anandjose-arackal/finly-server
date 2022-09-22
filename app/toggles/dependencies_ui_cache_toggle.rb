class DependenciesUiCacheToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/dependencies_ui_cache_enabled', false
  end
end
