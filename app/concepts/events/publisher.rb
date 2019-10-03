class Events::Publisher
  extend Dry::Monads[:result]

  def self.broadcast(routing_key, message, current_user: nil, persistence: true, ignore_failure: false)
    AsyncBroadcast.(routing_key, message, current_user: current_user, persistence: persistence)
    SyncBroadcast.(routing_key, message, current_user: current_user, ignore_failure: ignore_failure)
  end

  def self.broadcast_to_listener(listener_class, message, current_user: nil)
    ListenerBroadcast.(listener_class, message, current_user: current_user)
  end

  class Record
    def self.Create(record, user, role, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.create",
                                  Payload.for_record(record, user, :create, options.merge(role: role)),
                                  current_user: user
    end

    def self.Update(record, user, role, changes, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.update",
                                  Payload.for_record(record, user, :update, options.merge(role: role, changes: changes)),
                                  current_user: user
    end

    def self.Destroy(record, user, role, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.destroy",
                                  Payload.for_record(record, user, :destroy, options.merge(role: role)),
                                  current_user: user
    end

    def self.Transition(record, user, role, action, from_status, options = {})
      Events::Publisher.broadcast "#{record.class.event_channel}.#{action}",
                                  Payload.for_record(record, user, action, options.merge(role: role, from_status: from_status)),
                                  current_user: user
    end
  end

  def self.ToListener(listener_class, record, user, action, options = {})
    event = listener_class.event
    record_class = record.class.name == Class.name ? record : record.class
    if record_class.collection_event?(event)
      # Record should be an active record class to broadcast to listener
      raise "Error broadcasting to listener" unless record_class == record

      payload = Payload.for_collection(record, user, action, options = {})
    elsif record_class.record_event?(event)
      # Record should be an individual record to broadcast to listener
      raise "Error broadcasting to listener" if record_class == record

      payload = Payload.for_record(record, user, action, options)
    end

    Events::Publisher.broadcast_to_listener(listener_class, payload, current_user: user)
  end

  class Payload

    VALID_OPTIONS= %i(filters from_status role changes)
    def self.for_record(record, action_user, action, options: {})
      {
          record: record,
          action_user: action_user,
          action: action,
          options: options&.slice(VALID_OPTIONS)
      }.reject {|key, val| val.nil?}
    end

    def self.for_collection(record_class, action_user, action, options = {})
      {
          record_class: record_class,
          action_user: action_user,
          action: action,
          options: options&.slice(VALID_OPTIONS)
      }.reject {|key, val| val.nil?}
    end
  end

  # Broadcasting to a single listener
  # Sync or async depends on what is configured in listener class
  class ListenerBroadcast
    def self.call(listener_class, message, current_user: nil)
      if listener_class.async?
        listener_class.perform_async(payload)
      else
        listener_class.new.trigger(payload)
      end
    end
  end

  # Broadcasting the message synchronously to all listeners
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