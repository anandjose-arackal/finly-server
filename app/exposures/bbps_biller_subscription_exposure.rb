class BbpsBillerSubscriptionExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :subscription_id, record_attribute: :sequence_id
  attribute :biller, record_attribute: true, exposure: true
  attribute :biller_category_name, record_attribute: true
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

end