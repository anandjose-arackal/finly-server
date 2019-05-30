module Supporters::ErrorTracker

  attr_accessor :messages

  def has_errors?
    self.messages.present? and (self.messages[:error].present? or self.messages[:failure].present?)
  end

  def clear_messages
    self.messages = {error: [], failure: [], success: [], message: [], notice: []}
  end

  def add_message(type, message)
    return false if type.blank? or message.blank? or (type != :error and type != :failure and type != :success and type != :message and type != :notice)
    clear_messages if self.messages.blank?
    if message.is_a?(Array)
      messages[type].concat message
    elsif message.is_a?(String)
      messages[type] << message
    end
    true
  end

  def add_system_message(type, model, message)
    return if type.blank? or message.blank? or (type != :error and type != :failure and type != :success and type != :message and type != :notice)
    clear_messages if self.messages.blank?
    message = [message] unless message.is_a?(Array)
    system_message_type = SystemMessageType.id_for(type)
    message.each do |m|
      SystemMessage.create(messagable: model, content: m, system_message_type_id: system_message_type)
    end
  end

end