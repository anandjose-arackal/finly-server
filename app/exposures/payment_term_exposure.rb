class PaymentTermExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :days_after, record_attribute: true
  attribute :description, record_attribute: true
  attribute :default, record_attribute: true
  attribute :calculated_days_after, record_attribute: false do
    record.calculate_days_after
  end
end