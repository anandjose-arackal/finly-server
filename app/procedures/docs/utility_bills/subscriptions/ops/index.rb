class Docs::UtilityBills::Subscriptions::Ops::Index < Transactions::API

  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :index? )
  step Transactions::Resolver::Model(BbpsBillerSubscription)
  step :index!


  def index!(options, *)
    result = {
        'subscriptions': BbpsBillerSubscription.all
    }

    options['result'] = result
  end
end