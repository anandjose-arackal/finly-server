class Gatekeeper::Rules::BaseRule
  include RuleBook::Page, Observer::Observable

  book Gatekeeper::Master

end