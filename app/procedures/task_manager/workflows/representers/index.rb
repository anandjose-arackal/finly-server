class TaskManager::Workflows::Representers::Index < Representable::Decorator
  include Representable::JSON

  property :uuid
  property :name
  property :description
  property :model_class
  property :trigger_type
  property :task_schedule do
    property :every
    property :hour
    property :minute
    property :day_of_the_week
    property :day_of_the_month
  end

end