class Docs::UtilityBills::Billers::Authorizer
  def initialize(user, model)
    @user, @model = user, model
  end

  def show?
    true
  end
end