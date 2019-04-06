class Gatekeeper::Log < BaseOperation
  attr_accessor :verdict, :error_logger, :logger, :admin_user

  def user_model
    [AdminUser, User]
  end

  def initialize(verdict, params)
    self.error_logger = LogStashLogger.new(type: :file, path: 'log/logstash_gatekeeper_error.log', sync: true)
    self.logger = LogStashLogger.new(type: :file, path: 'log/logstash_gatekeeper.log', sync: true)
    self.user = RequestStoreUtil.current_user || params&.dig(:user)
    self.admin_user = RequestStoreUtil.current_admin_user || params&.dig(:admin_user)
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
    model_param = base_params.merge({user: user, company: user&.company, admin_user: admin_user})
    logstash_params = base_params.merge(
        {
            user: {
                id: user&.id,
                name: user&.name,
                email: user&.email
            },
            company: {
                id: user&.company_id,
                name: user&.company&.name
            },
            admin_user: {
                id: admin_user&.id,
                name: admin_user&.name,
                email: admin_user&.email
            },
        }
    )

    # Store in model
    blocker = GatekeeperBlock.new model_param
    unless blocker.valid?
      puts blocker.errors.full_messages
    end
    blocker.save

    # Logstash logger
    logger.info(logstash_params)

    # Slack

  end

  def base_params
    level = (self.verdict.level.to_s[/\d+/].to_i || 1)
    level = 1 if level < 1
    x_finly_rp = RequestStoreUtil.current_request.headers['X-Finly-RP'] || ''
    headers = Base64.decode64(x_finly_rp)
    {
        params: RequestStoreUtil.request_params,
        headers: headers,
        act: self.verdict.act.to_s,
        premise: self.verdict.premise.to_s,
        rule: self.verdict.rule.to_s,
        verdict: (self.verdict.message || self.verdict.description),
        level: level
    }
  end

  def add_message(type, message)
    return unless super(type, message)
    if type == :error
      self.error_logger.info message
    end
  end

end