class Gatekeeper::Checker < RuleBook::Chapter

  class Gatekeeper::Checker::Verdict < RuleBook::Verdict

    define_property :instance, :response_code, :require_otp, :message

  end

  act Gatekeeper::Registry
  verdict Gatekeeper::Checker::Verdict

end