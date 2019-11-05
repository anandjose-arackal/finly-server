class Docs::UtilityBills::Subscriptions::Ops::Show < Transactions::API
  step Model(BbpsBillerSubscription, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Subscriptions::Authorizer, :show?)
  # step Transactions::Resolver::Model(BbpsBillerSubscription)
end