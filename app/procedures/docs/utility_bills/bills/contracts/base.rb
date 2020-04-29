class Docs::UtilityBills::Bills::Contracts::Base < Reform::Form

  property :id
  property :subscription_id, validates: {presence: true}
  property :bbps_biller_id, validates: {presence: true}
  property :sequence_id

  property :department_id
  property :cost_center_id
  property :location_id
  property :company_id, validates: {presence: true}
  property :autofetched
  property :bill_validation_required

  property :category_id
  property :tax_rate_id
  property :hsn_sac

  property :order_number
  property :order_number_type

  # Should be used in update
  property :policy_id
  property :user_id

  # Other Details
  property :bill_date
  property :bill_number
  property :bill_period
  property :due_date

  # property :early_payment_fee_selected
  # property :late_payment_fee_selected
  # property :convenience_fee_selected
  property :disconn_tag
  property :bill_month
  property :pc
  property :early_payment_date
  property :api_response

  # property :user_id, validates: {presence: true}

  property :status_id, default: BbpsBillStatus.id_for(:open)

  property :amount, populate_if_empty: Amount do
    property :value, validates: {presence: true}, default: 0
    property :currency_id, validates: {presence: true}
  end

  property :late_payment_fee, populate_if_empty: Amount do
    property :value, validates: {presence: true}, default: 0
    property :currency_id, validates: {presence: true}
  end

  property :early_payment_fee, populate_if_empty: Amount do
    property :value, validates: {presence: true}, default: 0
    property :currency_id, validates: {presence: true}
  end

  property :convenience_fee, populate_if_empty: Amount do
    property :value, validates: {presence: true}, default: 0
    property :currency_id, validates: {presence: true}
  end

  property :total_amount, populate_if_empty: Amount do
    property :value, validates: {presence: true}, default: 0
    property :currency_id, validates: {presence: true}
  end

end