module Events::Consumer

  def self.included(base)
    base.extend ClassMethods
    base.include Dry::Monads[:result]
  end

  module ClassMethods
    def consumes_event!(event, consumer_key: nil, options: {})
      async! unless options&.dig(:sync)
      @event = event
      @event_options = options
      @consumer_key = consumer_key
      @consumes_event = true
      
      Events::Registry.add_event self, event, consumer_key

      if async?
        include Sneakers::Worker
        from_queue event, options
      end
    end

    def scheduled!(every:, hour:, minute:, day_of_the_week: nil, day_of_the_month: nil)
      @scheduled = true
      @schedule = {
          every: every,
          hour: hour,
          minute: minute,
          day_of_the_week: day_of_the_week,
          day_of_the_month: day_of_the_month,
      }

      async!
      validate_schedule

      Events::Registry.add_scheduled_job self
      setup_schedule_job
    end

    def consumer_key
      @consumer_key
    end

    def consumes_event?
      @consumes_event || false
    end

    def schedule
      @schedule
    end

    def scheduled?
      @scheduled || false
    end

    def async?
      @async || false
    end

    def event
      @event
    end

    protected
    def validate_schedule
      # Todo raise exception if the schedule is invalid
    end

    def setup_schedule_job
      frequency = schedule[:every]
      at = "#{schedule[:day_of_the_week]} " if schedule[:day_of_the_week]
      at += "#{schedule[:hour].to_s.rjust(2, '0')}:#{schedule[:minute].to_s.rjust(2, '0')}"
      # Todo handle day of the month
      Clockwork.every frequency, self.name, at: at do
        self.perform_async(:scheduled)
      end
    end

    def async!
      include Sidekiq::Worker
      @async = true
    end

  end

  def work(payload)
    perform payload
    ack! if respond_to?(:ack!)
  end

  def perform(payload)
    data = nil
    if payload.is_a?(Hash)
      data = payload
    elsif payload.is_a?(String)
      data = JSON.parse payload
    end

    data = data&.to_h&.with_indifferent_access
    raise 'Invalid payload' if data.nil? or data[:type].blank?

    decoded_data = Events::Serializer.decode(data)
    type = decoded_data[:type]
    message = decoded_data[:message]
    user = decoded_data&.dig(:current_user)

    # Todo load request store properties
    # request_store_properties = payload&.dig('request_store_properties')
    # RequestStoreUtil.from_hash request_store_properties

    receive(type, user, message)
  end

  def receive(type, user, message)
    case type
    when :schedule
      self.send("on_schedule") if self.respond_to?("on_schedule")
    when :event
      self.send("on_event", user: user, message: message) if self.respond_to?("on_event")
    end
  end

  # def on_schedule
  #   # implement me
  # end

  # def on_event(user, message)
  #   # implement me
  # end

end