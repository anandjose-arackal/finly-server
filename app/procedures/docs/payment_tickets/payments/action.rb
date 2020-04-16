class Docs::PaymentTickets::Payments::Action < ActionManager::API

  scope policy: Docs::PaymentTickets::Policy, model: Payment do

    action :redirect,
           :create,
           # permissions: :bank_payment_request_initiator,
           label: 'Create Payment Ticket',
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           url: 'payment_tickets/new'

    # action :export,
    #        :export,
    #        label: "Export",
    #        icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
    #        route: "payments.index",
    #        authorize: :export?

  end

end