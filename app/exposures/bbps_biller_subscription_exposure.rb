class BbpsBillerSubscriptionExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :biller, record_attribute: true, exposure: true
  attribute :biller_category_name, record_attribute: true

end