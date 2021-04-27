module Events::Consumer

  def self.included(base)
    base.extend ClassMethods
    base.include Dry::Monads[:result]
  end

  module ClassMethods
    def consumes_event!(*events, sync: false, options: {})
      async! unless sync
      @events = events
      @event_options = options
      @consumes_event = true

      events.each do |event|
        Events::Registry.add_event self, event
      end

      if async?
        include Hutch::Consumer
        consume(*events)

        # include Sneakers::Worker
        # from_queue event, options
      end
    end

    def async?
      @async || false
    end

    def events
      @events
    end

    protected

    def async!
      include Sidekiq::Worker
      @async = true
    end

  end

  def process(payload)
    perform payload.body
  end

  def perform(payload)
    data = nil
    if payload.is_a?(Hash)
      data = payload
    elsif payload.is_a?(String)
      data = JSON.parse payload
    end

    data = data&.to_h&.with_indifferent_access
    raise 'Invalid payload' if data.nil?

    decoded_data = Events::Serializer.decode(data)
    message = decoded_data[:message]
    user = decoded_data&.dig(:current_user)
    company = decoded_data&.dig(:current_company)

    # Todo load request store properties
    # request_store_properties = payload&.dig('request_store_properties')
    # RequestStoreUtil.from_hash request_store_properties

    ActsAsTenant.with_tenant company do
      work(user, message)
    end
  end

  def work(user, message)
    puts "Work called #{self.class.name}"
  end

  # def on_schedule
  #   # implement me
  # end

  # def work(user, message)
  #   # implement me
  # end

end