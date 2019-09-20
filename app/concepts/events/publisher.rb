module Events::Publisher

  def self.broadcast(routing_key, message, current_user: nil, persistence: true)
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

end