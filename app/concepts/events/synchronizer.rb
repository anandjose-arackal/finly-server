module Events::Synchronizer

  def self.for(type)
    case type
    when :database
      return DatabaseMonitor
    else
      raise "Invalid type of Events Synchronizer"
    end
  end

  private
  class DatabaseMonitor < TaskManager::API

    def self.register(model_class, event, &block)
      klass = Class.new(DatabaseMonitor)
      klass.setup model_class, event, &block
    end

    def self.setup(model_class, event, &block)
      raise "Model is not defined for Events Database::Monitor" if model_class.blank?
      raise "Queue is not defined for Events Database::Monitor" if event.blank?

      model model_class
      event event
      block block
      consumes_event! event
    end

    def self.model(model_class = NoObject)
      @model_class = model_class unless model_class == NoObject
      @model_class
    end

    def self.event(event = NoObject)
      @event = event unless event == NoObject
      @event
    end

    def self.block(block)
      @block = block if block.present?
      @block
    end

    def on_event(user, message)
      debugger
      records = self.class.model.with_event(self.class.event)
      records.each do |record|
        block&.call(record, user, message)
      end
    end

  end

end