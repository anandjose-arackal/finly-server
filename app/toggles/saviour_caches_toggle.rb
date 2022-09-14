class SaviourCachesToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/saviour_caches', false
  end

end
