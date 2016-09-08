# Used for handling multiple events. Pass the event classes to be handled they will be
# processed in the order they were passed
class Event::MultiEventBase < Event::Base

  def process
    events = self.events
    return if events.blank?
    unless events.is_a?(ActiveRecord::Relation) or events.is_a?(Array)
      events = [events]
    end
    events.each do |event|
      if event.is_a?(Class)
        event.(user, params)
      else
        event.run
      end
    end
  end

  # Pass the class names of the events to be triggered
  def events
    # [Event::Report::Submit::SetNotification, Event::Report::Submit::Logger]
  end

end