class Docs::UtilityBills::Billers::Ops::Show < Trailblazer::Operation

  step Model( BbpsBiller, :find )
  step Policy::Pundit( Docs::UtilityBills::Billers::Authorizer, :show? )

end