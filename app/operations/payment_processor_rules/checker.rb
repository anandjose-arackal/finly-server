class PaymentProcessorRules::Checker < RuleBook::Chapter

  class PaymentProcessorRules::Checker::Verdict < RuleBook::Verdict

    define_property :instance, :response_code, :message

  end

  act PaymentProcessorRules::Registry
  verdict PaymentProcessorRules::Checker::Verdict

end