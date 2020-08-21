class Events::Payload::Record

  VALID_OPTIONS ||= %i(filters from_status role changes)
  def self.call(record_class, action_user, action, options = {})
    {
        record_class: record_class,
        action_user: action_user,
        action: action,
        options: options&.slice(VALID_OPTIONS)
    }.reject {|key, val| val.nil?}
  end

end