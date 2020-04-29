class Docs::PaymentTickets::Payments::FilterConfig < Filters::API

  attribute :id, label: "ID", simple: true, type: :text
  attribute :payment_order_bank_payment_request_id, type: :text, simple: true, label: 'Payment Ticket ID'
  attribute :payment_status_id, label: "Status", type: :dropdown, simple: true, choices: Choices[:enum].(PaymentStatus)
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :payment_order_bank_payment_request_submitted_at, type: :datetime
  attribute :payment_order_bank_payment_request_approved_at, type: :datetime
  attribute :payment_order_scheduled_at, label: "Scheduled On", type: :datetime, simple: true
  attribute :processed_at, label: "Processed On", type: :datetime
  attribute :last_retried_at, label: "Last Retried On", type: :datetime
  attribute :payment_order_bank_payment_request_policy_id, type: :dropdown, simple: true, choices: Choices[:auto_complete].("policies")
  attribute :amount_value, type: :number, label: 'Amount'
  attribute :receiving_user_vendor_id, type: :dropdown, label: 'Vendor', choices: Choices[:auto_complete].("vendor"), simple: true
  custom_fields :purchase_order, prefix: :purchase_order_parent
  custom_fields :invoice, prefix: :invoice

end