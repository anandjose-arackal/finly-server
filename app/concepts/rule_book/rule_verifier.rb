class RuleBook::RuleVerifier
  include Supporters::ErrorTracker

  attr_accessor :executed

  def initialize(attributes)
    attributes.each do |attribute_name, attribute_value|
      ##### Method one #####
      # Works just great, but uses something scary like eval
      # self.class.class_eval {attr_accessor attribute_name}
      # self.instance_variable_set("@#{attribute_name}", attribute_value)

      ##### Method two #####
      # Manually creates methods for both getter and setter and then
      # sends a message to the new setter with the attribute_value
      self.class.send(:define_method, "#{attribute_name}=".to_sym) do |value|
        instance_variable_set("@" + attribute_name.to_s, value)
      end
      self.class.send(:define_method, "set_#{attribute_name}".to_sym) do |value|
        instance_variable_set("@" + attribute_name.to_s, value)
      end

      self.class.send(:define_method, attribute_name.to_sym) do
        instance_variable_get("@" + attribute_name.to_s)
      end

      self.send("#{attribute_name}=".to_sym, attribute_value)
    end
    self.executed = false
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