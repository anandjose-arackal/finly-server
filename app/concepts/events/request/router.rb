class Events::Request::Router
  extend Dry::Monads[:result]

  def self.Send(routing_key, message, current_user: nil, ignore_failure: false)
    AsyncBroadcast.(routing_key, message, current_user: current_user, persistence: persistence)
    SyncBroadcast.(routing_key, message, current_user: current_user, ignore_failure: ignore_failure)
  end

  # Broadcasting the message synchronously to all listeners
  class SyncBroadcast
    extend Dry::Monads[:result]

    def self.call(routing_key, message, current_user: nil, ignore_failure: false)
      results = []
      has_failure = false
      Events::Registry.request_handlers(routing_key, type: :sync).each do |handler|
        result = handler.new.trigger(current_user, message)
        data = {result: result, handler: handler, success: result.success?}

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

  # Broadcasting the message asynchronously to all listeners
  class AsyncBroadcast
    def self.call(routing_key, message, current_user: nil)
      payload = {message: message, current_user: (current_user || RequestStoreUtil.current_user)}
      payload.reject! { |k, v| v.nil? } # Remove all nil values
      Events::Registry.request_handlers(routing_key, type: :async).each do |handler|
        handler.perform_async(
            Events::Serializer.encode(payload).to_json,
            routing_key: routing_key,
        )
      end
    end
  end

end