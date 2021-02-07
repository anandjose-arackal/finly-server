class VpOldUiToggle < ApplicationToggle

  def old_ui_enabled?
    feature_flag 'release/vp_old_ui#enabled', true
  end

end