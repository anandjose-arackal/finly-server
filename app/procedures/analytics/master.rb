class Analytics::Master

  def self.register(model, klass)
    registry(model) << klass
  end

  def self.registry(model)
    @registry ||= {}
    @registry[model] ||= []
  end

end