class GstinExposure < Exposures::API

  attribute :gstin, record_attribute: true
  attribute :legal_name_of_business, record_attribute: true
  attribute :state, record_attribute: true
  attribute :date_of_registration, record_attribute: true
  attribute :constitution_of_business, record_attribute: true
  attribute :taxpayer_type, record_attribute: true
  attribute :status, record_attribute: true
  attribute :api_response, record_attribute: true
  attribute :api_provider, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :address, record_attribute: true
  attribute :trade_name, record_attribute: true

end