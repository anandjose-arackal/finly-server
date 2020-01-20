class TaskManager::Workflows::Resolver < Resolver::API

  def load(params)
    entity.where(user: user)
  end

end