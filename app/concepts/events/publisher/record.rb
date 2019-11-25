class Events::Publisher::Record < Events::Publisher

  def self.Create(record, user, options = {})
    broadcast "#{record.class.event_channel}.create",
              Events::Payload::Record.(record, user, :create, options),
              current_user: user
  end

  def self.Update(record, user, changes, options = {})
    broadcast "#{record.class.event_channel}.update",
              Events::Payload::Record.(record, user, :update, options.merge(changes: changes)),
              current_user: user
  end

  def self.Destroy(record, user, options = {})
    broadcast "#{record.class.event_channel}.destroy",
              Events::Payload::Record.(record, user, :destroy, options),
              current_user: user
  end

  def self.Transition(record, user, action, from_status, options = {})
    broadcast "#{record.class.event_channel}.#{action}",
              Events::Payload::Record.(record, user, action, options.merge(from_status: from_status)),
              current_user: user
  end
end