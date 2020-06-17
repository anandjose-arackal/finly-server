class GstinLocationExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :vendor, record_attribute: true, exposure: true, includes: [:vendor]
  attribute :gstin_master, record_attribute: true, exposure: true, includes: [:gstin_master]
  attribute :gstin, record_attribute: true
  attribute :state, record_attribute: true, exposure: true, includes: [:state]
  attribute :poc_name, record_attribute: true
  attribute :poc_mobile_number, record_attribute: true
  attribute :poc_email, record_attribute: true
  attribute :poc_fax, record_attribute: true
  attribute :poc_designation, record_attribute: true
  attribute :location, record_attribute: true
  attribute :address, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :deleted_at, record_attribute: true

end