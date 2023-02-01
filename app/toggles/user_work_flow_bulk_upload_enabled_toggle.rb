# release/user_workflow#bulk_import
class UserWorkFlowBulkUploadEnabledToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/user_workflow#bulk_import', false
    end
end
  