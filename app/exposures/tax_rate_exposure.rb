class TaxRateExposure < Exposures::API

  attribute :name, record_attribute: true
  attribute :rate, record_attribute: true
  attribute :cgst, record_attribute: true
  attribute :sgst, record_attribute: true
  attribute :igst, record_attribute: true
  attribute :display_name do
    "#{rate}% - #{name}"
  end

end