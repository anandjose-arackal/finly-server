class Docs::UtilityBills::Bills::Ops::Show < Transactions::API
  step Model(BbpsBill, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :show?)
  # step Transactions::Resolver::Load(model: BbpsBillerSubscription)
end