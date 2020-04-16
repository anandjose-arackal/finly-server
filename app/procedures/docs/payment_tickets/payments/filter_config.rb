class Docs::PaymentTickets::Payments::FilterConfig < Filters::API

  attribute :id, label: "ID", simple: true, type: :text
  attribute :payment_order_bank_payment_request_id, type: :text, simple: true, label: 'Payment Ticket ID'
  attribute :payment_status_id, label: "Status", type: :dropdown, simple: true, choices: Choices[:enum].(PaymentStatus)

end