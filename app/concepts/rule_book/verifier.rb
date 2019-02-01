class RuleBook::Verifier
  include Supporters::ErrorTracker

  attr_accessor :event, :options, :description, :block, :page, :attrs, :executed, :params

  def self.with_properties(*properties)
    Class.new(self) do
      include DynamicProperty

      define_property :instance, *properties

    end
  end

  def initialize(rule, params)
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

  def success?
    self.executed and not has_errors?
  end

  def failed?
    self.executed and has_errors?
  end

end