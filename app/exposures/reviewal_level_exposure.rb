class ReviewalLevelExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :level_number, record_attribute: true
  attribute :name, record_attribute: true
  attribute :policy, record_attribute: true, exposure: true, includes: [:policy]

end