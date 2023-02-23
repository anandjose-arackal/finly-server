class LeanFetchCallToggle < ApplicationToggle

  def enabled?
    feature_flag 'release/lean_fetch', false
  end

end