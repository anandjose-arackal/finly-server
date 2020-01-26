# Used for evaluating procs, klasses and symbols
class Transactions::Evaluator

  def self.eval(exec_context, function, *args, proc: true, klass: true, symbol: true)
    if function.is_a?(Proc) and proc
      eval_proc(exec_context, function, *args)
    elsif function.is_a?(Class) and klass
      eval_class(function, *args)
    elsif function.is_a?(Symbol) and symbol
      eval_symbol exec_context, function, *args
    else
      function
    end
  end

  def self.eval_proc(exec_context, function, *args)
    if function.is_a?(Proc)
      exec_context.instance_eval(*args, &function)
    else
      function
    end
  end

  def self.eval_class(klass, *args)
    if klass.is_a?(Class)
      klass.call(*args)
    else
      klass
    end
  end

  def self.eval_symbol(exec_context, function, *args)
    raise "#{function} is not defined" unless exec_context.respond_to?(function)

    exec_context.send(function, *args)
  end

  # def self.execute_if_proc(exec_context, function, *args)
  #   if function.is_a?(Proc)
  #     exec_context.instance_eval(*args, &function)
  #   else
  #     function
  #   end
  # end
  #
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