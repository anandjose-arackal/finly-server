# release/user_workflow#bulk_import
class UserWorkFlowBulkUploadEnabled < ApplicationToggle
    def enabled?
      feature_flag 'release/user_workflow#bulk_import', false
    end
end
  