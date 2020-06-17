class Docs::P2P::Agreements::Action < ActionManager::API

  scope policy: Docs::P2P::Agreements::Policy, model: PaymentAgreement do

    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "payment_agreements.index"

    action :redirect,
           :create,
           format: 'primary',
           permissions: :payment_agreement_initiator,
           label: 'Add Agreement',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'agreements/new'

  end

end