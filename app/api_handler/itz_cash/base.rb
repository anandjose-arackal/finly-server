class ItzCash::Base < BaseHandler
  attr_accessor :response_code, :response_description, :file_logger

  def parse
    self.parsed_response = self.response.body.split(',') rescue []
    if self.parsed_response.present?
      self.response_code = parsed_response[0]
      self.response_description = parsed_response.last
    end
  end

  def init
    super
    self.file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_itz_cash_api.log', sync: true)
  end

  def process
    super
    # logging the request / response
    p = self.path
    params = post_params
    response = self.response.body
    status_code = self.response_code
    self.file_logger.info(
        file_logger_params(
            path: p,
            post_params: params,
            response: response,
            status: status_code,
            itz_cash_action: env_key
        )
    )
  end

  def file_logger_base_params
    {}
  end

  def file_logger_params(logger_params)
    file_logger_base_params.merge(logger_params).merge(request_id: Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s))
  end

  def success_response_code
    [0]
  end

  def success?
    super and self.response_code.present? and (success_response_code.include?(self.response_code.to_f))
  end

  def failure
    if response_code.present? and not response_code.to_i == 0 and messages[:error].blank?
      error_message = (self.response_description or Constants::ItzCash::ERROR_CODES[response_code.to_i])
      error_message = 'Unknown error while performing the action' if error_message.blank?
      add_message :error, error_message
    end
    super
  end

end