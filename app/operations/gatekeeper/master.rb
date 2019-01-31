class Gatekeeper::Master
  include RuleBook::Index, Observer::Master

  set_rule_class RuleBook::Rule.with_attrs(:response_code)
  set_rules_path "#{Rails.root}/app/gatekeeper/rules"

end