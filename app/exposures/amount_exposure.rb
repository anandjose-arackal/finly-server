class AmountExposure < Exposures::API

  attribute :value, record_attribute: true
  attribute :currency, record_attribute: true, exposure: true

end