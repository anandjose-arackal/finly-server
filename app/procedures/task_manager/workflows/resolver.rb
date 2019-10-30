class TaskManager::Workflows::Resolver < ApplicationPolicy::Scope

  def resolve(filters: {})
    scope.where(user: @user)
  end

end