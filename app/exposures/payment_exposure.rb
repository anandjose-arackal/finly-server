class PaymentExposure < Exposures::API
  attribute :date, record_attribute: true
  attribute :narration, record_attribute: true
  attribute :reference_id, record_attribute: true
  attribute :gl_name, record_attribute: true
  attribute :vendor, exposure: true do
    next unless record.receiving_user_type == 'YesBankVendor'

    record.receiving_user
  end
  # attribute :beneficiary, record_attribute: true
  attribute :amount, record_attribute: true, exposure: true
  attribute :initiating_user, record_attribute: true, exposure: true
  attribute :initiating_account, record_attribute: true, exposure: true
  attribute :receiving_user, record_attribute: true, exposure: true
  attribute :receiving_account, record_attribute: true, exposure: true
  attribute :status, record_attribute: true, exposure: true
  attribute :payment_order_id, record_attribute: true, exposure: true
  attribute :payment_order, record_attribute: true, exposure: true
  attribute :payment_mode, record_attribute: true

end