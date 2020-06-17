class BbpsBillerExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :biller_name, record_attribute: true
  attribute :biller_category_name, record_attribute: true

end