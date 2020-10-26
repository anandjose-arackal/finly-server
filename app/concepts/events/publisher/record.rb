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
    # Since destroy is handled in +before_destroy+ callback, there are scenarios where the job is being executed
    # before the record is actually destroyed. Adding a 10 seconds delay to avoid this scenario
    broadcast "#{record.class.event_channel}.destroy",
              Events::Payload::Record.(record, user, :destroy, options),
              current_user: user, wait: 10.seconds
  end

  def self.Transition(record, user, action, from_status, options = {})
    broadcast "#{get_event_channel(record)}.#{action}",
              Events::Payload::Record.(record, user, action, options.merge(from_status: from_status)),
              current_user: user
  end

  def self.get_event_channel(record)
    record.class.respond_to?(:event_channel) ? record.class.event_channel : record.class.table_name
  end
end