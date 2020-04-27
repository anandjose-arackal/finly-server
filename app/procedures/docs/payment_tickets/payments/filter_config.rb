class Docs::PaymentTickets::Payments::FilterConfig < Filters::API

  attribute :id, label: "ID", simple: true, type: :text
  attribute :payment_order_bank_payment_request_id, type: :text, simple: true, label: 'Payment Ticket ID'
  attribute :payment_status_id, label: "Status", type: :dropdown, simple: true, choices: Choices[:enum].(PaymentStatus)
  attribute :date, type: :date, simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :payment_order_bank_payment_request_submitted_at, type: :datetime
  attribute :payment_order_bank_payment_request_approved_at, type: :datetime
  attribute :payment_order_scheduled_at, label: "Scheduled Date", type: :datetime, simple: true
  attribute :payment_order_bank_payment_request_policy_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].("policies")
  attribute :payment_order_amount_requested_value, type: :amount, label: 'Requested Amount'
  attribute :payment_order_amount_processed_value, type: :amount, label: 'Processed Amount'
  attribute :receiving_user_vendor_id, type: :dropdown, label: 'Vendor', choices: Choices[:auto_complete].("vendor"), simple: true

end