class Docs::PaymentTickets::FilterConfig < Filters::API

  TICKET_TYPES = [
      {id: "beneficiary", name: "Beneficiary Payment"},
      {id: "invoice", name: "Invoice Payment"},
      {id: "purchase_order", name: "Purchase Order"},
      {id: "security_deposit", name: "Security Deposit"},
      {id: "utility_bill", name: "Utility Bill"},
  ]

  index_builder Docs::PaymentTickets::Index

  attribute :id, label: 'Payment Ticket ID', type: :text, simple: true
  attribute :payment_order_payments_id, label: "Payment ID", type: :text, simple: true
  attribute :status_id, type: :dropdown, choices: Choices[:enum].(BankPaymentRequestStatus)
  attribute :ticket_type, type: :dropdown, simple: true, choices: Choices[:list].(*TICKET_TYPES)
  attribute :name, type: :text, simple: true
  attribute :created_at, type: :datetime
  attribute :updated_at, type: :datetime
  attribute :submitted_at, type: :datetime
  attribute :approved_at, type: :datetime
  attribute :payment_order_scheduled_at, label: "Scheduled Date", type: :datetime, simple: true
  attribute :policy_id, type: :dropdown, simple: true, choices: Choices[:lookup].("policies")
  attribute :payment_order_amount_requested_value, type: :number, label: 'Requested Amount'
  attribute :payment_order_amount_processed_value, type: :number, label: 'Processed Amount'
  attribute :payment_order_payments_receiving_user_vendor_id, type: :dropdown, label: 'Vendor', choices: Choices[:lookup].("vendors"), simple: true
  attribute :owner_id, label: "Created By", type: :dropdown, choices: Choices[:lookup].("users")
  attribute :controlling_level_level_number, label: "Controlling Level", type: :number, simple: true
  attribute :controlling_user, label: "Controlling User", type: :dropdown, simple: true, choices: Choices[:lookup].("users")
  custom_fields :purchase_order, prefix: :payment_order_payments_purchase_order_parent
  custom_fields :invoice, prefix: :payment_order_payments_invoice

end