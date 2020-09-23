class PaymentTermExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :description, record_attribute: true
  attribute :default, record_attribute: true

end