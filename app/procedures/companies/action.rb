class Companies::Action < ActionManager::API
  scope policy: Companies::Policy, model: Company do
  end
end
