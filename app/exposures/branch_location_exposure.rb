class BranchLocationExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :location_code, record_attribute: true
  attribute :gstin, record_attribute: true
  attribute :state, record_attribute: true
  attribute :gl_code, record_attribute: true
  attribute :address_1, record_attribute: true
  attribute :address_2, record_attribute: true
  attribute :address, record_attribute: true

end