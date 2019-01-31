module RuleBook::Index

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Alias class method for observers_path
    def set_rules_path(path)
      self.observers_path path
    end

    def set_rule_class(klass)
      observers_master[:rule_class] = klass
    end

    def rule_class
      observers_master[:rule_class] || RuleBook::Rule
    end
  end

end