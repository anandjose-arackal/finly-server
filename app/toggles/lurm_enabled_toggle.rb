# release/approval_workflow_bulk_upload_enabled
class LrumEnabledToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/approval_workflow_bulk_upload_enabled', false
    end
end
  