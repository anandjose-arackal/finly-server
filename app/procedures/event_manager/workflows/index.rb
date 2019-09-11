class EventManager::Workflows::Index < Transactions::API

  step Transactions::Resolver::Model(EventWorkflow, scope: :default, filter: true, paginate: true)

end
