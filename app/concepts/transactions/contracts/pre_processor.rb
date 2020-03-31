class Transactions::Contracts::PreProcessor

  def self.pre_processors
    @sanitizers ||= []
  end

  def self.register(klass)
    pre_processors << klass
  end

  def self.execute(args)
    pre_processors.each do |sanitizer|
      sanitizer.new(args).run!
    end
  end

end
