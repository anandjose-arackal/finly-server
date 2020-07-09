class MacroJobExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :macro, record_attribute: true, exposure: true, includes: [:macro]
  attribute :started_at, record_attribute: true
  attribute :ended_at, record_attribute: true
  attribute :execution_time, record_attribute: true
  attribute :status, record_attribute: true, exposure: true

end