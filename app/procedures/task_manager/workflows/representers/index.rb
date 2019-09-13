class TaskManager::Workflows::Representers::Index < Representable::Decorator
  include Representable::JSON

  property :uuid
  property :name
  property :description
  property :model_class
  property :trigger_type

end