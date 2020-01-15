require 'dry/monads'

class Events::Publisher
  extend Dry::Monads[:result]

  protected

  def self.broadcast(routing_key, message, current_user: nil, consumer_key: NoObject, persistence: true, ignore_failure: false)
    raise "Consumer key cannot be nil" if consumer_key.nil?

    payload = {message: message, current_user: (current_user || RequestStoreUtil.current_user), type: :event}
    payload.reject! {|k, v| v.nil?} # Remove all nil values

    Async.(routing_key, payload, current_user: current_user, persistence: persistence, consumer_key: consumer_key)
    Sync.(routing_key, payload, current_user: current_user, ignore_failure: ignore_failure, consumer_key: consumer_key)
  end

  # Broadcasting the message synchronously to all listeners
  class Sync
    extend Dry::Monads[:result]

    def self.call(routing_key, payload, current_user: nil, ignore_failure: false, consumer_key:)
      if consumer_key != NoObject
        consumer = Events::Registry.find_by_consumer_key(consumer_key)
        execute_consumer(consumer, payload, current_user) if consumer
      else
        execute_all_consumers(routing_key, payload, current_user, ignore_failure)
      end
    end

    def self.execute_consumer(consumer, payload, current_user)
      return Failure("Consumer not found") if consumer.nil?

      consumer.new.perform(payload)
    end

    def self.execute_all_consumers(routing_key, payload, current_user, ignore_failure)
      results = []
      has_failure = false
      Events::Registry.sync_events(routing_key).each do |consumer|
        result = execute_consumer(consumer, payload, current_user)
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
    def self.call(routing_key, payload, current_user: nil, persistence: true, consumer_key:)
      if consumer_key == NoObject
        publish_to_all_consumers(routing_key, payload, persistence)
      else
        publish_to_consumer(consumer_key, payload)
      end
    end

    def self.publish_to_consumer(consumer_key, payload)
      # Find the consumer and run a background job
      Events::Registry.find_by_consumer_key(consumer_key)&.perform_async(Events::Serializer.encode(payload))
    end

    def self.publish_to_all_consumers(routing_key, payload, persistence)
      # Publish to all consumers
      sneakers_client.publish(
          Events::Serializer.encode(payload).to_json,
          routing_key: routing_key,
          persistence: persistence
      )
    end

    def self.sneakers_client
      @client ||= Sneakers::Publisher.new
    end
  end


end