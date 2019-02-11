class Gatekeeper::Master
  include RuleBook::Index

  rule_book_index_setup

  # class Gatekeeper::Master::Checker < RuleBook::Verifier
  #   include Helpers::UserSessionsHelper, DynamicProperty
  #   define_property :instance, :response_code
  #
  #   def invalidate_session(status_id, *reason)
  #     super(status_id, *reason)
  #     add_message :error, reason
  #   end
  #
  #   def success?
  #     super and [nil, 200].include?(response_code)
  #   end
  # end
  #
  # rule_verifier Gatekeeper::Master::Checker
  rule_verifier RuleBook::Verifier.with_properties(:response_code)
  rules_path "#{Rails.root}/app/operations/gatekeeper/rules"

end