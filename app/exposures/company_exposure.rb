class CompanyExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :active, record_attribute: true
  attribute :configuration, record_attribute: true, exposure: true
  attribute :base_currency, record_attribute: true, exposure: true

end
