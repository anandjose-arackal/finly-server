class Gatekeeper::Checker < RuleBookDSL::Chapter
  act Gatekeeper::Registry

  class Gatekeeper::Checker::Verdict < RuleBookDSL::Verdict

    define_property :instance, :response_code, :require_otp

  end

  verdict Gatekeeper::Checker::Verdict

end