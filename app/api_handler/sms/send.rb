class Sms::Send < BaseHandler

  attr_accessor :file_logger

  def init
    super
    self.params = {} if self.params.nil?

    self.file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_msg91_api.log', sync: true)
  end

  def file_logger_base_params
    {}
  end

  def file_logger_params(logger_params)
    file_logger_base_params.merge(logger_params).merge(request_id: Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s))
  end

  def message
    params[:message]
  end

  def mobile_numbers
    mob_num = (params[:mobile_number] or params[:mobile_numbers])
    users = (params[:user] or params[:users] or user)

    if mob_num.present?
      unless mob_num.is_a?(Array)
        mob_num = [mob_num]
      end
    elsif users.present?
      if users.is_a?(User)
        mob_num = [users.mobile_number]
      elsif users.is_a?(ActiveRecord::Relation)
        mob_num = users.pluck(:mobile_number)
      end
    end
    mob_num
  end

  def http_request_type
    :get
  end

  def env_key
    'msg91_custom_message'
  end

  def query_params
    mob_num = mobile_numbers
    if mob_num.blank?
      add_message :error, 'Error sending SMS. Mobile number cannot be blank'
      return
    end
    msg = message
    if msg.blank?
      add_message :error, 'Message cannot be blank'
      return
    end
    mobile_numbers = mob_num.map{ |s| "91#{s}" }
    list = mobile_numbers.join(",")
    {
        authkey: authentication_key,
        mobiles: list,
        message: msg,
        sender: 'FINLYX',
        route: 4,
        country: 91,
        response: 'json'
    }
  end

  def process
    super
    # logging the request / response
    p = self.path
    params = query_params
    response = JSON.parse(self.response.body) rescue {}
    self.file_logger.info(
        file_logger_params(
            path: p,
            post_params: params,
            msg91_response: response
        )
    )
  end

  def success
    Sms::Send::SuccessPresenter.new(user, {result: 'Success'})
  end

  class Sms::Send::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter

    attr_accessor :result

    def init
      self.result = params[:result]
    end

  end

  protected
  def authentication_key
    Constants::WELCOME_MESSAGE_AUTH_KEY
  end

end