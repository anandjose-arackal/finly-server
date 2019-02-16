class Gatekeeper::Log < BaseOperation
  attr_accessor :verdict

  GATEKEEPER_ERROR_LOGGER = LogStashLogger.new(type: :file, path: 'log/logstash_gatekeeper_error.log', sync: true)
  GATEKEEPER_LOGGER = LogStashLogger.new(type: :file, path: 'log/logstash_gatekeeper.log', sync: true)

  def initialize(verdict, params)
    self.user = RequestStoreUtil.current_user || params&.dig(:user)
    super(self.user, params)
    self.verdict = verdict
  end

  def pre_validate
    params_present?
  end

  def validate
    unless self.verdict.present?
      add_message :error, 'Verdict is required for logging'
      return
    end

    if not self.verdict.executed?
      add_message :error, 'Verdict has not yet been executed before being logged'
    elsif self.verdict.success?
      add_message :error, 'Skipping logging as verdict has run successfully'
    end
  end

  def process
    model_param = base_params.merge({user: user, company: user&.company})
    logstash_params = base_params.merge(
        {
            user: {
                id: user.id,
                name: user.name,
                email: user.email
            },
            company: {
                id: user.company_id,
                name: user.company.name
            }
        }
    )

    blocker = GatekeeperBlock.new model_param
    unless blocker.valid?
      puts blocker.errors.full_messages
    end
    blocker.save
    # GATEKEEPER_LOGGER.info(logstash_params) unless Rails.env.test?
  end

  def base_params
    {
        params: RequestStoreUtil.request_params,
        headers: RequestStoreUtil.current_request.headers,
        act: self.verdict.act.to_s,
        premise: self.verdict.premise.to_s,
        rule: self.verdict.rule.to_s,
        verdict: (self.verdict.message || self.verdict.description)
    }
  end

  def add_message(type, message)
    return unless super(type, message)
    if type == :error
      GATEKEEPER_ERROR_LOGGER.info message unless Rails.env.test?
    end
  end

end