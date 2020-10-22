class GlobalSearchToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/global_search#enabled', false
  end

end