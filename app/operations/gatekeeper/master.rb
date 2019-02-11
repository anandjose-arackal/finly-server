class Gatekeeper::Master
  include RuleBook::Index

  rule_book_index_setup

  class Gatekeeper::Master::Checker < RuleBook::Verifier
    include DynamicProperty

    define_property :instance, :response_code

  end

  rule_verifier Gatekeeper::Master::Checker
  # rule_verifier RuleBook::Verifier.with_properties(:response_code)
  rules_path "#{Rails.root}/app/operations/gatekeeper/rules"

end