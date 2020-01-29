class Transactions::Contracts::Sanitizers::Base

  def self.run(contract, type, name, options, block)

  end

  def self.register!
    Transactions::Contracts::Sanitizer.register(self)
  end

end
