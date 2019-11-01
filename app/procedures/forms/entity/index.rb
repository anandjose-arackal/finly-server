class Forms::Entity::Index < Transactions::API

  step Transactions::Resolver::Model(TaskWorkflow, scope: :default, filter: true, paginate: true)

end