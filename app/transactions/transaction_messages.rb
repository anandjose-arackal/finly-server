module TransactionMessages

  def self.included(base)
    base.extend(ClassMethods)
  end

  def on_info(options, key, message)
    add_message options, :info, key, message
    true
  end

  def on_success(options, key, message)
    add_message options, :success, key, message
    true
  end

  def on_error(options, key, message)
    add_message options, :error, key, message
    false
  end

  def add_message(options, type, key, message)
    Transaction.add_message options, type, key, message
  end

  module ClassMethods
    def on_info(options, key, message)
      add_message options, :info, key, message
      true
    end

    def on_success(options, key, message)
      add_message options, :success, key, message
      true
    end

    def on_error(options, key, message)
      add_message options, :error, key, message
      false
    end

    def add_message(options, type, key, message)
      case type
      when :error, :errors
        message_type = 'result.operation.errors'
      when :success, :info
        message_type = "result.operation.#{type}"
      else
        raise "Invalid message type #{type}. It has to be of type error, success or info"
      end
      options[message_type] = {} if options[message_type].nil?
      options[message_type][key] = [] if options[message_type][key].nil?
      message = [message] unless message.respond_to?(:each)
      message.each {|m| options[message_type][key] << m}
    end
  end
end