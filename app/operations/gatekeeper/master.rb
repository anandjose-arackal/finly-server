class Gatekeeper::Master
  include RuleBook::Index, Observer::Master

  # class Gatekeeper::Master::Checker < RuleBook::Verifier
  #   properties :response_code
  #
  #   def success?
  #     super and [nil, 200].include?(response_code)
  #   end
  # end

  # rule_verifier Gatekeeper::Master::Checker
  rule_verifier RuleBook::Verifier.with_properties(:response_code)
  rules_path "#{Rails.root}/app/operations/gatekeeper/rules"

end