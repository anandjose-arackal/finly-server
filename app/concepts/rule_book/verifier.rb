class RuleBook::Verifier
  include Supporters::ErrorTracker

  attr_accessor :event, :options, :description, :block, :page, :attrs, :executed, :params

  def self.with_properties(*properties)
    Class.new(self) do
      properties.each do |property|
        # Setter based on params being sent or not
        self.send(:define_method, "#{property}=".to_sym) do |value|
          instance_variable_set("@" + property.to_s, value)
        end

        # Getter/setter based on params being sent or not
        self.send(:define_method, property.to_sym) do |value = NoObject|
          if value != NoObject
            instance_variable_set("@" + property.to_s, value)
          end
          instance_variable_get("@" + property.to_s)
        end
      end
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

  def self.properties(*props)
    props.each do |property|
      define_method "#{property}".to_sym do |value = NoObject|
        if value != NoObject
          instance_variable_set("@" + property.to_s, value)
        end
        instance_variable_get("@" + property.to_s)
      end

      define_method "#{property}=" do |value|
        instance_variable_set("@" + property.to_s, value)
      end
    end
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