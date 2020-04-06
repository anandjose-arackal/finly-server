class Docs::Trips::Ops::Show < Transactions::API

  step Model(Trip, :find_by_uuid)
  step Policy::Pundit(Docs::Trips::Policies::Actions, :show?)

end