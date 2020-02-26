class Gatekeeper::Event
  include Supporters::ErrorTracker

  ENABLED = true #Rails.env.production? || Rails.env.test?

  attr_accessor :event, :params

  def self.call(event, params = {})
    self.new(event, params).run
  end

  def initialize(event, params = {})
    self.event = event
    self.params = params
  end

  def run
    return success_verdict require_otp: false unless ENABLED
    return success_verdict require_otp: false if RequestStoreUtil.current_user.class.name == AdminUser.name

    if RequestStoreUtil.security_policy and not RequestStoreUtil.security_policy.gatekeeper.enabled?
      return success_verdict require_otp: false
    end

    require_otp = false
    response_message = nil
    Gatekeeper::Registry.subscribers(event)&.each do |rule|
      result = rule.verdict(self.params)
      unless result.success?
        Gatekeeper::Log.(result, RequestStoreUtil.request_params)
        return result
      end
      require_otp ||= result.require_otp
      response_message ||= result.response_message
    end
    success_verdict require_otp: require_otp, response_message: response_message
  end

  def success_verdict(require_otp:, response_message: nil)
    verdict = Gatekeeper::Checker::Verdict.success_verdict
    verdict.require_otp(require_otp) if require_otp
    verdict.response_message(response_message) if response_message
    verdict
  end

end