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

    def self.register(model_class, event, options = {}, &block)
      klass = Class.new(DatabaseMonitor)
      klass.setup model_class, event, options, &block
    end

    def self.setup(model_class, event, options, &block)
      raise "Model is not defined for Events Database::Monitor" if model_class.blank?
      raise "Queue is not defined for Events Database::Monitor" if event.blank?

      model model_class
      event event
      block block
      options options
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

    def self.options(options = NoObject)
      @options = options unless options == NoObject
      @options ||= {}
    end

    def self.global_scope?
      !!options[:global_scope]
    end

    def on_event(user, message)
      records = self.class.model.with_event(self.class.event)
      unless self.class.global_scope?
        # return if not of global scope and user is not provided
        return unless user.present?

        company_key = self.class.options[:company_key] || :company_id
        records = records.where("#{company_key}": user.company_id)
      end
      records.each do |record|
        block&.call(record, user, message)
      end
    end
  end

end