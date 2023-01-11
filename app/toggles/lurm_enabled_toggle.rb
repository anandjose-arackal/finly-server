# release/lurm_enabled
class LrumEnabledToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/lurm_enabled', false
    end
end
  