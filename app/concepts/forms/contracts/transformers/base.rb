class Forms::Contracts::Transformers::Base

  def validates
    @validates ||= []
  end

  def validate
    @validate ||= []
  end

  def initialize(name, value)
    raise "To be handled"
  end

  def self.register(key)
    Forms::Contracts::Transformers::Registry.register(key, self)
  end


end