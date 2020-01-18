class TaskManager::Workflows::Resolver < Transactions::Resolver::Scope

  def resolve(user, params)
    Success(scope.where(user: user))
  end

end