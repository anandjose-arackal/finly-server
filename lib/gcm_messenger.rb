module GcmMessenger
  # todo critical to remove this before deploy
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  def self.expense_review(user, expense)
    gcm_sender_ids = get_sender_ids user, expense
    message = "#{user.name} has #{expense.status} the expense : #{expense.merchant}"
    json_payload = generate_json_payload user, expense, message
    send_notification json_payload, gcm_sender_ids
  end

  def self.send_notification(message, users=[], type)
    begin
      payload = generate_json_payload
      gcm = GCM.new("AIzaSyAo-LOXQBqKlAujuV_VzpevSx2itK_350I")
      options = {data: {message: message}, collapse_key: "updated_score"}
      gcm.send(users, options)
    rescue => e
      logger.error e.message
      e.backtrace.each { |line| logger.error line }
    end
  end

  def self.generate_json_payload(user, expense, message)
    {username: user.name, user_id: user.id, expense_user_id: expense.user_id, expense_id: expense.id, user_type_id: user.user_type_id, message: message}
  end

end