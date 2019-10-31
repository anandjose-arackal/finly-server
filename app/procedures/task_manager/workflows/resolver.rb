class TaskManager::Workflows::Resolver < ApplicationPolicy::Resolver

  def resolve(filters)
    scope.where(user: @user).include(:task_schedule)
  end

end