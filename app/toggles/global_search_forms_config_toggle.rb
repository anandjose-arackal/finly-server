# release/global_search_forms_config_enabled
class GlobalSearchFormsConfigToggle < ApplicationToggle

    def enabled?
      feature_flag 'release/global_search_forms_config_enabled', false
    end
  
  end
  