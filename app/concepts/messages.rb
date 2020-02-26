class Messages

  class Messages::Task
    def self.SuccessMessage(message)
      Transactions::Task.build id: "messages.success.add" do |context, **|
        Transactions::API.on_success(context, :base, message)
      end
    end

    def self.FailureMessage(message)
      Transactions::Task.build id: "messages.success.add" do |context, **|
        Transactions::API.on_error(context, :base, message)
      end
    end
  end

  def self.Info(options, key, message)
    Add(options, :info, key, message)
    true
  end

  def self.Success(options, key, message)
    Add(options, :success, key, message)
    true
  end

  def self.Error(options, key, message)
    Add(options, :error, key, message)
    false
  end

  def self.Add(options, type, key, message)
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

  def self.AddSchema(options, errors_list)
    errors_list.to_h.each do |attr, err_list|
      if err_list.is_a?(Hash)
        AddSchema(options, err_list)
      else
        err_list.each do |e|
          Error options, attr, e
        end
      end
    end
    false
  end
end