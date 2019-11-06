class Docs::UtilityBills::Bills::Ops::Index < Transactions::API

  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :index?)
  # step Transactions::Resolver::Model(BbpsBills)
  step :index!


  def index!(options, *)
    result = {
        "bills" => BbpsBill.all
    }

    options['result'] = result
  end
end