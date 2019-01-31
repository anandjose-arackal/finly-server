# RuleBook::Index is the master which holds all the rules defined against this master
#
# Requirements:
#   Observer::Master has to be explicitly included
#   set_rules_path has to be called to ensure all rules are loaded in development environment
#   set_rules_class: In case you want additional attributes to be captured in rules (ex: response_code in auth ruleset),
#       then call set_rules_class RuleBook::Rule.with_attrs(<Necessary attributes as symbols>)
#
# Usage:
# Class X
#  include RuleBook::Index, Observer::Master
#
#  set_rules_path "path/to/rule set"
#  set_rules_class RuleBook::Rule.with_attrs(:response_code)
#
#
# end
module RuleBook::Index

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Alias class method for observers_path
    def rules_path(path)
      self.observers_path path
    end

    def rule_verifier(klass = NoObject)
      if klass != NoObject
        observers_master[:rule_class] = klass
      end
      observers_master[:rule_class] || RuleBook::Verifier
    end

  end

end