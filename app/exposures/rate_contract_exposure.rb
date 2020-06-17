class RateContractExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :renewable, record_attribute: true
  attribute :vendor, record_attribute: true, exposure: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :note, record_attribute: true
  attribute :rate_contract_id, record_attribute: :rate_contract_number

end