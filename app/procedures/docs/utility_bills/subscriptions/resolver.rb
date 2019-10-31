class Docs::UtilityBills::Subscriptions::Resolver < ApplicationPolicy::Resolver
  def resolve(filters)
    scope.where(user: @user)
  end
end