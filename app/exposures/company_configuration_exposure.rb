class CompanyConfigurationExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :legal_entity_name, record_attribute: true
  attribute :start_date, record_attribute: true
  attribute :end_date, record_attribute: true

end
