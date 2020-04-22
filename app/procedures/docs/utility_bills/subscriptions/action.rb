class Docs::UtilityBills::Subscriptions::Action < ActionManager::API

  scope policy: Docs::UtilityBills::Subscriptions::Policy, model: BbpsBillerSubscription do
    action :export,
           :export,
           label: "Export",
           icon: "https://img.icons8.com/windows/17/708090/--checkmark-yes.png",
           route: "utility_subscriptions.index",
           authorize: :export?

  end

end