require 'dry/monads'

class Events::Publisher
  extend Dry::Monads[:result]

  protected

  def self.broadcast(routing_key, message, current_user: nil, ignore_failure: false, wait: nil)

    payload = {message: message, current_user: (current_user || RequestStoreUtil.current_user)}
    payload.reject! { |k, v| v.nil? } # Remove all nil values

    Async.(routing_key, payload, current_user: current_user, wait: wait)
    Sync.(routing_key, payload, current_user: current_user, ignore_failure: ignore_failure)
  end

  # Broadcasting the message synchronously to all listeners
  class Sync
    extend Dry::Monads[:result]

    def self.call(routing_key, payload, current_user: nil, ignore_failure: false)
      execute_consumers(routing_key, payload, current_user, ignore_failure)
    end


    def self.execute_consumers(routing_key, payload, current_user, ignore_failure)
      results = []
      has_failure = false
      Events::Registry.sync_events(routing_key).each do |consumer|
        result = consumer.new.perform(payload)
        result ||= Failure("Could not process the event")
        data = {result: result, consumer: consumer, success: result.success?}

        if result.success?
          data[:value] = result.value!
        else
          data[:failure] = result.failure
          has_failure = true
        end

        results << data
        return Failure(results) if result.failure and not ignore_failure
      end
      has_failure ? Failure(results) : Success(results)
    end
  end

  # Broadcasting the payload asynchronously to all listeners
  class Async
    def self.call(routing_key, payload, current_user: nil, wait: nil)
      json_payload = Events::Serializer.encode(payload).as_json
      if wait.present?
        PublishJob.perform_in(wait, routing_key, json_payload)
      else
        # Publish to all consumers
        PublishJob.new.perform(routing_key, json_payload)
      end
    end

    class PublishJob
      include Sidekiq::Worker

      def perform(routing_key, payload)
        begin
          Hutch.connect # unless Hutch.connected?
        rescue Hutch::ConnectionError => e
          raise e if Rails.env.production?

          return
        end

        Hutch.publish(routing_key, payload)
      end

    end
  end


end