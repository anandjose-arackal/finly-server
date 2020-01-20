module Transactions::Messages

  def self.SuccessMessage(message)
    Transactions::Task.build id: "messages.success.add" do |context, **|
      Transactions::API.on_success(context, :base, message)
    end
  end

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

  def on_schema_error(options, errors_list)

  end

  def add_message(options, type, key, message)
    # type = [:info, :success, :error]
    # key => key for any field | pass 'base' if its not associated with any field key
    Transactions::API.add_message options, type, key, message
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

    def on_schema_error(options, errors_list)
      errors_list.to_h.each do |attr, err_list|
        if err_list.is_a?(Hash)
          on_schema_error(options, err_list)
        else
          err_list.each do |e|
            on_error options, attr, e
          end
        end
      end
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