class YesBankVendorExposure < Exposures::API
  include Concerns::ErpSyncConcern
  
  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :email, record_attribute: true
  attribute :business_name, record_attribute: true
  attribute :trade_name, record_attribute: true
  attribute :vendor_id, record_attribute: true
  attribute :vendor_country, record_attribute: true
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
  attribute :created_by_id, record_attribute: true
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

  attribute :bank_accounts, includes: [:bank_accounts], exposure: true do
    record.bank_accounts.unscope(:order).order(default_account: :desc, created_at: :desc)
  end

  attribute :default_bank_account, includes: [:bank_accounts], exposure: true do
    record.bank_accounts.default_accounts&.first
  end

  attribute :gstin_location, includes: [:gstin_locations], exposure: true do
    record.gstin_locations&.first
  end
  attribute :gstin_locations, includes: [:gstin_locations], exposure: true, record_attribute: true

  attribute :deactivated, record_attribute: :deactivated?

  # attribute :vendor_tds_rates, record_attribute: true, exposure: true
end
