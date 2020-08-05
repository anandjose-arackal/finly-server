class TaxRateExposure < Exposures::API

  attribute :name, record_attribute: true
  attribute :rate, record_attribute: true
  attribute :cgst, record_attribute: true
  attribute :sgst, record_attribute: true
  attribute :igst, record_attribute: true
  attribute :display_name do
    "#{rate}% - #{name}"
  end
  attribute :cgst_account_number, record_attribute: :cgst_internal_id
  attribute :sgst_account_number, record_attribute: :sgst_internal_id
  attribute :igst_account_number, record_attribute: :igst_internal_id

end