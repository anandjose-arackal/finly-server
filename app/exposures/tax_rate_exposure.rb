class TaxRateExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :rate, record_attribute: true
  attribute :cgst, record_attribute: true
  attribute :sgst, record_attribute: true
  attribute :igst, record_attribute: true
  attribute :display_name do
    "#{rate}% - #{name}"
  end

end