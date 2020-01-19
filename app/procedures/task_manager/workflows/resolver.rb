class TaskManager::Workflows::Resolver < Resolver::API

  def load(user, params)
    Success(scope.where(user: user))
  end

end