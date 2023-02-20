# release/forms#dynamic_comments_json
class FormsDynamicCommentsLoadingToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/forms#dynamic_comments_json', false
    end
end
  