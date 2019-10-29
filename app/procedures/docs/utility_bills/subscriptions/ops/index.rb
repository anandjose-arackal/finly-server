class Docs::UtilityBills::Subscriptions::Ops::Index < Trailblazer::Operation

  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :index? )
  step :index!


  def index!(options, *)
    options['subscriptions'] = BbpsBillerSubscription.all
  end

end