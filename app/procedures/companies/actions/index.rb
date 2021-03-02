class Companies::Actions::Index < ActionManager::API
  scope policy: Companies::Policy, model: Company do
  end
end
