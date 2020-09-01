class BbpsBillerSubscriptionExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :subscription_id, record_attribute: :sequence_id
  attribute :biller, record_attribute: true, exposure: true
  attribute :customer_param_key_1, record_attribute: true
  attribute :customer_param_value_1, record_attribute: true
  attribute :customer_param_key_2, record_attribute: true
  attribute :customer_param_value_2, record_attribute: true
  attribute :customer_param_key_3, record_attribute: true
  attribute :customer_param_value_3, record_attribute: true
  attribute :customer_param_key_4, record_attribute: true
  attribute :customer_param_value_4, record_attribute: true
  attribute :customer_param_key_5, record_attribute: true
  attribute :customer_param_value_5, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true
  attribute :category, record_attribute: true, exposure: true
  attribute :auto_fetchable, record_attribute: true
  attribute :location, record_attribute: true, exposure: true
  attribute :cost_center, record_attribute: true, exposure: true
  attribute :department, record_attribute: true, exposure: true
  attribute :status, record_attribute: true, exposure: true
  attribute :policy, record_attribute: true, exposure: true
  attribute :hsn_sac, record_attribute: true
  attribute :tax_rate, record_attribute: true, exposure: true
  attribute :last_paid_at, record_attribute: true
  attribute :controlling_level, record_attribute: true, exposure: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :pocs, record_attribute: true, exposure: true
  attribute :mobile_number, record_attribute: true
  attribute :support_bill_validation, record_attribute: true
  attribute :customer_name, record_attribute: true
  attribute :customer_email, record_attribute: true
  attribute :customer_aadhar_number, record_attribute: true
  attribute :customer_pan, record_attribute: true
end