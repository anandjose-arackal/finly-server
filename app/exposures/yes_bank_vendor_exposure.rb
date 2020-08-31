class YesBankVendorExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :business_name, record_attribute: true
  attribute :trade_name, record_attribute: true
  attribute :vendor_id, record_attribute: true
  attribute :vendor_type, record_attribute: true, exposure: true
  attribute :rcm_enabled, record_attribute: true
  attribute :pan, record_attribute: true
  attribute :msme_registered, record_attribute: true
  attribute :msme_registration_number, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :policy, record_attribute: true, exposure: true
  attribute :status, record_attribute: true, exposure: true
  attribute :gst_registered, record_attribute: true
  attribute :authorized, record_attribute: true
  attribute :gl_name do
    record.business_name
  end
  attribute :payment_term, record_attribute: true, exposure: true
  attribute :display_name, record_attribute: true
  attribute :mobile_number, record_attribute: true
  attribute :state_code, record_attribute: true, exposure: true
  attribute :description, record_attribute: true
  attribute :address, record_attribute: true
end
