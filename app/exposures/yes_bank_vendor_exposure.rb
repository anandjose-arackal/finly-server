class YesBankVendorExposure < Exposures::API

  attribute :business_name, record_attribute: true
  attribute :trade_name, record_attribute: true
  attribute :vendor_id, record_attribute: true
  attribute :vendor_type, record_attribute: true, exposure: true
  attribute :rcm_enabled, record_attribute: true
  attribute :pan_number, record_attribute: true
  attribute :msme_registered, record_attribute: true
  attribute :msme_registration_number, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :policy, record_attribute: true, exposure: true
  attribute :status, record_attribute: true, exposure: true
  attribute :gl_name do
    record.business_name
  end

end