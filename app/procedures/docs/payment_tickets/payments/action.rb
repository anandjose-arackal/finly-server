class Docs::PaymentTickets::Payments::Action < ActionManager::API

  scope policy: Docs::PaymentTickets::Policy, model: Payment do

    action :redirect,
           :create,
           permissions: :bank_payment_request_initiator,
           format: 'primary',
           label: 'Create Payment Ticket',
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           url: 'new_payment_ticket'

  end

end