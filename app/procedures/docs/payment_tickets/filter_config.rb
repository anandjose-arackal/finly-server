class Docs::PaymentTickets::FilterConfig < Filters::API

  attribute :id, label: 'Payment Ticket ID', type: :number, simple: true
  attribute :payment_order_payments_id, label: "Payment ID", type: :number, simple: true
  attribute :status_id, type: :dropdown, choices: Choices[:enum].(BankPaymentRequestStatus)
  attribute :name, type: :text, simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :submitted_at, type: :datetime
  attribute :approved_at, type: :datetime
  attribute :payment_order_scheduled_at, label: "Scheduled Date", type: :datetime, simple: true
  attribute :policy_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].("policies")
  attribute :payment_order_amount_requested_value, type: :number, label: 'Requested Amount'
  attribute :payment_order_amount_processed_value, type: :number, label: 'Processed Amount'
  attribute :payment_order_payments_receiving_user_vendor_id, type: :dropdown, label: 'Vendor', choices: Choices[:auto_complete].("vendor"), simple: true

end