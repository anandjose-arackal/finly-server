class TaskManager::Actions::BaseAction

  def self.define_action(klass_name, options = {}, &block)
    return nil unless klass_name and block_given?

    klass = Class.new(self)
    klass.setup klass_name, options
    klass.instance_eval &block
    klass
  end

  def self.setup(klass_name, options)
    @klass_name = klass_name
    @klass_options = options
  end

  def self.call(user, message ,input)
    self.new.run(user, message ,input)
  end

  def self.run(func)
    @runner = func
  end

  def self.runner
    @runner
  end

  def run(user, message ,input)
    self.class.runner&.call(user, message, input)
  end

end