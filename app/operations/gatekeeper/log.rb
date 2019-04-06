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
    notify_slack(base_params)
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

  def notify_slack(params)
    level = params[:level]
    return if level < 2

    yellow = '#BDB76B'
    red = '#FF0000'
    color = level > 3 ? red : yellow

    fields = []
    fields << {
        "title": "Premise",
        "value": params[:premise],
        "short": false
    }

    fields << {
        "title": "Rule",
        "value": params[:rule],
        "short": false
    }

    if user.present?
      fields << {
          "title": "User",
          "value": "#{user&.id} - #{user.name}",
          "short": false
      }
    end

    if user&.company.present?
      fields << {
          "title": "Company",
          "value": "#{user&.company&.id} - #{user&.company&.name}",
          "short": false
      }
    end

    if admin_user.present?
      fields << {
          "title": "Custom Success",
          "value": admin_user.name,
          "short": false
      }
    end

    if params[:username].present?
      fields << {
          "title": "Authentication username",
          "value": params[:username],
          "short": false
      }
    end

    attachment = {
        # "fallback": "Required plain-text summary of the attachment.",
        "color": color,
        # "pretext": "Level #{level} violation",
        "author_name": "Gatekeeper",
        "title": "Level #{level} violation",
        "text": params[:verdict],
        "fields": fields,
        "ts": Time.now.to_i
    }

    SLACK_NOTIFIER.ping nil, attachments: [attachment]
  end

end