class PaymentProcessorRules::Event
  include Supporters::ErrorTracker

  attr_accessor :event, :params

  def self.call(event, params = {})
    self.new(event, params).run
  end

  def initialize(event, params = {})
    self.event = event
    self.params = params
  end

  def run
    require_otp = false
    PaymentProcessorRules::Registry.subscribers(event)&.each do |rule|
      result = rule.verdict(self.params)
      unless result.success?
        PaymentProcessorRules::Log.(result, params)
        return result
      end
      require_otp ||= result.require_otp
    end
    verdict = PaymentProcessorRules::Checker::Verdict.success_verdict
    verdict.require_otp(require_otp)
    verdict
  end

end