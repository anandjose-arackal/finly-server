class Transactions::Contracts::Sanitizer

  def self.sanitizers
    @sanitizers ||= []
  end

  def self.register(klass)
    sanitizers << klass
  end

  def self.sanitize(contract, type, name, options, block)
    sanitizers.each do |sanitizer|
      sanitizer.run(contract, type, name, options, block)
    end
  end

end
