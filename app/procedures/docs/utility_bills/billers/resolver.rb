class Docs::UtilityBills::Billers::Resolver < Resolver::API

  entity BbpsBiller

  def load(params)
    BbpsBiller.all
  end
end