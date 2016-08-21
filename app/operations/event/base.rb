class Event::Base < BaseOperation

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

  def events

  end

end