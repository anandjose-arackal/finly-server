class Gatekeeper::RuleRunner < RuleBook::Rule

  attr_accessor :event, :options, :description, :block, :response_code, :klass, :success

  validates :event, presence: true
  validates :description, presence: true
  validates :block, presence: true
  validates :klass, presence: true

  def initialize(klass, event, options, description, block)
    self.klass = klass
    self.event = event
    self.options = options
    self.description = description
    self.block = block
  end

  def run
    unless valid?
      raise "Rule error: #{errors.full_messages} for #{self.klass&.name}"
    end
    process
  end

  def process

  end

end