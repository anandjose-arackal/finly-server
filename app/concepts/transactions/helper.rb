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

  # # Migrated to Transactions::Evaluator
  # def self.execute_if_proc(exec_context, function, *args)
  #   if function.is_a?(Proc)
  #     exec_context.instance_eval(*args, &function)
  #   else
  #     function
  #   end
  # end

  # def self.execute_function(exec_context, function, *args)
  #   if function.is_a?(Proc)
  #     execute_if_proc(exec_context, function, *args)
  #   elsif function.is_a?(Class)
  #     function.call(*args)
  #   elsif function.is_a?(Symbol)
  #     raise "#{function} is not defined" unless self.respond_to?(function)
  #     exec_context.send(function, *args)
  #   else
  #     function
  #     # raise "Invalid function #{function}"
  #   end
  # end

end