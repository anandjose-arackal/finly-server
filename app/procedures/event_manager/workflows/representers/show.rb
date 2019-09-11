class EventManager::Workflows::Representers::Show < Representable::Decorator
  include Representable::JSON

  property :uuid
  property :name
  property :description
  property :trigger_type
  property :event_schedule do
    property :every
    property :hour
    property :minute
    property :day_of_the_week
    property :day_of_the_month
  end
  property :event_key
  property :conditions

end