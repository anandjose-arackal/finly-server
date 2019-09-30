class Events::Publisher
  extend Dry::Monads[:result]

  def self.broadcast(routing_key, message, current_user: nil, persistence: true, ignore_failure: false)
    AsyncBroadcast.(routing_key, message, current_user: current_user, persistence: persistence)
    SyncBroadcast.(routing_key, message, current_user: current_user, ignore_failure: ignore_failure)
  end

  class Record
    def self.Create(record, user, role, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.create",
                                  Payload.for(record, user, :create, role, options: options)
    end

    def self.Update(record, user, role, changes, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.update",
                                  Payload.for(record, user, :update, role, changes: changes, options: options)
    end

    def self.Destroy(record, user, role, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.destroy",
                                  Payload.for(record, user, :destroy, role, options: options)
    end

    def self.Transition(record, user, role, action, from_status, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.#{action}",
                                  Payload.for(record, user, action, role, from_status: from_status, options: options)
    end
  end

  class Payload
    def self.for(record, action_user, action, role, changes: nil, from_status: nil, options: {})
      {
          record: record,
          action_user: action_user,
          action: action,
          role: role,
          from_status: from_status,
          changes: changes,
          options: options
      }.reject {|key, val| val.nil?}
    end
  end

  class SyncBroadcast
    extend Dry::Monads[:result]

    def self.call(routing_key, message, current_user: nil, ignore_failure: false)
      results = []
      has_failure = false
      Events::Registry.listeners_for(routing_key, type: :sync).each do |listener|
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