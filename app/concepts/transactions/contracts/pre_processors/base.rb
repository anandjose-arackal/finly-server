class Transactions::Contracts::PreProcessors::Base
  attr_accessor :args

  def initialize(args)
    self.args = args
  end

  def run!

  end

  def self.register!
    Transactions::Contracts::PreProcessor.register(self)
  end

  def contract
    args[:contract]
  end

  def contract=(value)
    args[:contract] = value
  end

  def type
    args[:type]
  end

  def type=(value)
    args[:type] = value
  end

  def name
    args[:name]
  end

  def name=(value)
    args[:name] = value
  end

  def options
    args[:options]
  end

  def options=(value)
    args[:options] = value
  end

  def block
    args[:block]
  end

  def block=(value)
    args[:block] = value
  end

end
