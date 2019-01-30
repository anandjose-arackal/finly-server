class Gatekeeper::Master
  include RuleBook::Index, Observer::Master

  rules_path "#{Rails.root}/app/gatekeeper/rules"

end