class Events::Payload::Record

  VALID_OPTIONS ||= %i(filters from_status changes)
  def self.call(record, action_user, action, options = {})
    {
        record: record,
        action_user: action_user,
        action: action,
        options: options&.slice(VALID_OPTIONS)
    }.reject {|key, val| val.nil?}
  end

end