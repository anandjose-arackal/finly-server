class BbpsBillExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :sequence_id, record_attribute: true
  attribute :subscription, record_attribute: true, exposure: true, includes: [:subscription]
  attribute :custom_param_key_1, record_attribute: true
  attribute :custom_param_value_1, record_attribute: true
  attribute :custom_param_key_2, record_attribute: true
  attribute :custom_param_value_2, record_attribute: true
  attribute :custom_param_key_3, record_attribute: true
  attribute :custom_param_value_3, record_attribute: true
  attribute :custom_param_key_4, record_attribute: true
  attribute :custom_param_value_4, record_attribute: true
  attribute :custom_param_key_5, record_attribute: true
  attribute :custom_param_value_5, record_attribute: true
  attribute :user, record_attribute: true, exposure: true, includes: [:user]
  attribute :created_by, record_attribute: :user, exposure: true, includes: [:user]
  attribute :status, record_attribute: true, exposure: true, includes: [:status]
  attribute :bill_number, record_attribute: true
  attribute :bill_date, record_attribute: true
  attribute :due_date, record_attribute: true
  attribute :due_in_days do
    next unless record.due_date.present?

    days = record.due_date - Date.today
    next unless days >= 0

    days
  end
  attribute :paid_at, record_attribute: true
  attribute :transaction_id, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :total_amount, record_attribute: true, exposure: true, includes: [:total_amount]
  attribute :cost_center, record_attribute: true, exposure: true, includes: [:cost_center]
  attribute :location, record_attribute: true, exposure: true, includes: [:location]
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :controlling_level, record_attribute: true, exposure: true, includes: [:controlling_level]
  attribute :policy, record_attribute: true, exposure: true, includes: [:policy]

end