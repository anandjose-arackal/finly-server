class Docs::UtilityBills::Subscriptions::Action < ActionManager::API

  scope policy: Docs::UtilityBills::Subscriptions::Policy, model: BbpsBillerSubscription do
    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "utility_subscriptions.index"

    action :redirect,
           :create,
           format: 'primary',
           permissions: :utility_bill_master_initiator,
           label: 'Add Subscription',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'utility_bill_master'

  end

end