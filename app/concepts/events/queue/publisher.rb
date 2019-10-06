class Events::Queue::Publisher
  extend Dry::Monads[:result]

  def self.broadcast(routing_key, message, current_user: nil, persistence: true, ignore_failure: false)
    AsyncBroadcast.(routing_key, message, current_user: current_user, persistence: persistence)
    SyncBroadcast.(routing_key, message, current_user: current_user, ignore_failure: ignore_failure)
  end

  class Record
    def self.Create(record, user, role, options = {})
      Events::Queue::Publisher.broadcast "#{record.class.event_channel}.create",
                                  Events::Payload::Record.(record, user, :create, options.merge(role: role)),
                                  current_user: user
    end

    def self.Update(record, user, role, changes, options = {})
      Events::Queue::Publisher.broadcast "#{record.class.event_channel}.update",
                                  Events::Payload::Record.(record, user, :update, options.merge(role: role, changes: changes)),
                                  current_user: user
    end

    def self.Destroy(record, user, role, options = {})
      Events::Queue::Publisher.broadcast "#{record.class.event_channel}.destroy",
                                  Events::Payload::Record.(record, user, :destroy, options.merge(role: role)),
                                  current_user: user
    end

    def self.Transition(record, user, role, action, from_status, options = {})
      Events::Queue::Publisher.broadcast "#{record.class.event_channel}.#{action}",
                                  Events::Payload::Record.(record, user, action, options.merge(role: role, from_status: from_status)),
                                  current_user: user
    end
  end

  # Broadcasting the message synchronously to all listeners
  class SyncBroadcast
    extend Dry::Monads[:result]

    def self.call(routing_key, message, current_user: nil, ignore_failure: false)
      results = []
      has_failure = false
      Events::Registry.queue_listeners(routing_key, type: :sync).each do |listener|
        result = listener.new.trigger(current_user, message)
        data = {result: result, listener: listener, success: result.success?}

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
    def self.call(routing_key, message, current_user: nil, persistence: true)
      payload = {message: message, current_user: (current_user || RequestStoreUtil.current_user)}
      payload.reject! {|k, v| v.nil?} # Remove all nil values
      client.publish(
          Events::Serializer.encode(payload).to_json,
          routing_key: routing_key,
          persistence: persistence
      )
    end

    def self.client
      @client ||= Sneakers::Publisher.new
    end
  end

end