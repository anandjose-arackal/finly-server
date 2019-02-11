class RuleBook::Verifier
  include Supporters::ErrorTracker

  attr_accessor :rule, :event, :options, :description, :block, :page, :attrs, :executed, :params, :failed

  def self.with_properties(*properties)
    Class.new(self) do
      include DynamicProperty

      define_property :instance, *properties

    end
  end

  def initialize(rule, params)
    self.rule = rule
    self.params = params
    rule.to_h.each do |attr, value|
      self.send "#{attr}=", value if respond_to?(attr)
    end
    self.executed = false
    init
  end

  def init
    # For initializing custom variables in subclasses
  end

  def verify
    self.instance_eval(&block)
    self.executed = true
    self
  end

  def executed?
    !!self.executed
  end

  def success?
    not failed?
  end

  def failed?
    self.executed? and !!self.failed
  end

  def fail
    self.failed = true
  end

  def message
    self.rule.description
  end

end