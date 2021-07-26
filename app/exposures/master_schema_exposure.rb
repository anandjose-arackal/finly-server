class MasterSchemaExposure < Exposures::API
  attribute :name, record_attribute: true
  attribute :master_key, record_attribute: true
  attribute :active, record_attribute: true
end