class Forms::Entity::Resolver < ApplicationPolicy::Scope

  def resolve(filters: {})
    scope.where(company_id: @user.company_id)
  end

end