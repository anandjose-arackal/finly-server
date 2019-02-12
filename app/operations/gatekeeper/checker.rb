class Gatekeeper::Checker < RuleBookDSL::Chapter

  class Gatekeeper::Checker::Verdict < RuleBookDSL::Verdict

    define_property :instance, :response_code, :require_otp

  end

  act Gatekeeper::Registry
  verdict Gatekeeper::Checker::Verdict

end