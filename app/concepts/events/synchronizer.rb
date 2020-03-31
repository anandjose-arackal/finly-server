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

    def self.sync(model_class, event, options = {}, &block)
      klass = Class.new(DatabaseMonitor)
      klass.setup model_class, event, options, &block
    end

    def self.setup(model_class, event, options={}, &block)
      raise "Model is not defined for Events Database::Monitor" if model_class.blank?
      raise "Queue is not defined for Events Database::Monitor" if event.blank?

      model model_class
      event event
      block block
      options options
      consumes_event! event, name: options[:name]
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

    def self.options(options = NoObject)
      @options = options unless options == NoObject
      @options ||= {}
    end

    def work(user, message)
      records = self.class.model.with_event(self.class.event)
      return unless user.present?

      records = records.where(company_key: user.company_id)
      records.each do |record|
        block&.call(record, user, message)
      end
    end
  end

end