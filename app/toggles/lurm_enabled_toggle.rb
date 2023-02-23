# release/approval_workflow#bulk_import
class LurmEnabledToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/approval_workflow#bulk_import', false
    end
end
  