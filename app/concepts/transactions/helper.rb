class Transactions::Helper

  def self.options_to_args(parameters, options)
    arguments = []
    parameters.each do |params|
      key = params[1]
      var = options[key] || options[key.to_s]
      arguments << var
    end
    arguments.shift
    arguments
  end

  def self.execute_function(function, *args)
    if function.is_a?(Proc) or function.is_a?(Class)
      function.call(*args)
    elsif function.is_a?(Symbol)
      raise "#{function} is not defined" unless self.respond_to?(function)
      self.send(function, *args)
    else
      raise "Invalid function #{function}"
    end
  end

end