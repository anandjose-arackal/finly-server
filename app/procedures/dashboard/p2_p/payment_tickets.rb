class Dashboard::P2P::PaymentTickets < Dashboard::IndexCard

  index_route 'payment_tickets'
  path 'payment_tickets'
  created_by :owner_id
  scope_status BankPaymentRequestStatus::GROUP_PROCESSING,
               BankPaymentRequestStatus::GROUP_PENDING_CREDIT,
               BankPaymentRequestStatus::GROUP_SCHEDULED,
               BankPaymentRequestStatus::GROUP_PARTIALLY_COMPLETED,
               BankPaymentRequestStatus.id_for(:credited),
               BankPaymentRequestStatus::GROUP_FAILED

end