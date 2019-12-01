class TaskManager::Workflows::Resolver < Transactions::Resolver::Scope

  def load(params)
    scope.where(user: @user)
  end

end