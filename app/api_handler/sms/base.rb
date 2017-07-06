class Sms::Base < BaseHandler

  def message

  end

  def mobile_numbers
    return if params.blank?
    mob_num = (params[:mobile_number] or params[:mobile_numbers])
    users = (params[:user] or params[:users])

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

  def post_params
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
    {
        authkey: authentication_key,
        mobiles: mob_num,
        message: msg,
        sender: 'FINLYX',
        route: 4,
        country: 91,
        response: 'json'
    }
  end

  def success
    Sms::Base::SuccessPresenter.new(user, {result: 'Success'})
  end

  class Sms::Base::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter

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