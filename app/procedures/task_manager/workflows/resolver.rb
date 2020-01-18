class TaskManager::Workflows::Resolver < Transactions::Resolver::Scope

  def load(user, params)
    Success(scope.where(user: user))
  end

end