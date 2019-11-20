class Docs::UtilityBills::Bills::Ops::Destroy < Transactions::API

  step Model(BbpsBill, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :destroy?)

  step :destroy!

  def destroy!(options, model:, **)
    model.destroy
  end
end