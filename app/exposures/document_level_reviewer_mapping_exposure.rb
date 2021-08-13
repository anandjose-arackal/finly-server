class DocumentLevelReviewerMappingExposure < Exposures::API
  attribute :id, record_attribute: true
  attribute :level_number, record_attribute: true
  attribute :action_taken_at, record_attribute: true
  attribute :action_taken_by, record_attribute: true
  attribute :level, record_attribute: true
end