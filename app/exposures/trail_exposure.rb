class TrailExposure< Exposures::API

  attribute :id, record_attribute: true
  attribute :action_taken_by, record_attribute: :action_user, exposure: true, includes: [:action_user]
  attribute :action_taken_at, record_attribute: :created_at
  attribute :level, record_attribute: action_level,exposure: true

end