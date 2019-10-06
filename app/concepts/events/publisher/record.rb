class Events::Publisher::Record < Events::Publisher

  def self.Create(record, user, role, options = {})
    broadcast "#{record.class.event_channel}.create",
                                Events::Payload::Record.(record, user, :create, options.merge(role: role)),
                                current_user: user
  end

  def self.Update(record, user, role, changes, options = {})
    broadcast "#{record.class.event_channel}.update",
                                Events::Payload::Record.(record, user, :update, options.merge(role: role, changes: changes)),
                                current_user: user
  end

  def self.Destroy(record, user, role, options = {})
    broadcast "#{record.class.event_channel}.destroy",
                                Events::Payload::Record.(record, user, :destroy, options.merge(role: role)),
                                current_user: user
  end

  def self.Transition(record, user, role, action, from_status, options = {})
    broadcast "#{record.class.event_channel}.#{action}",
                                Events::Payload::Record.(record, user, action, options.merge(role: role, from_status: from_status)),
                                current_user: user
  end
end