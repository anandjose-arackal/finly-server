# API call to MSG91's servers to send a custom SMS message

class CustomMessage::Create < BaseHandler

  attr_accessor :message

  def pre_validate
    if params.blank? or params[:mobile_number].blank?
      add_message :error, 'Mobile number cannot be blank'
    end
  end

  def env_key
    'msg91_custom_message'
  end

  def init
    super()
    self.message = params[:message]
    # the default message is the custom message that is sent while inviting a user via mobile number
    if message.nil?
      self.message = 'You have been invited to use Finly. Please contact your manager to activate your account'
    end
  end

  def process
    # post payload as JSON instead of "www-form-urlencoded" encoding:
    self.response = self.connection.get do |req|
      req.url path
      req.params = {
          authkey: authentication_key,
          mobiles: mobile_numbers,
          message: message,
          sender: 'FINLYX',
          route: 4,
          country: 91,
          response: 'json'
      }
    end
  end

  def parse

  end

  def success
    CustomMessage::Create::SuccessPresenter.new(user, {result: 'Success'})
  end

  class CustomMessage::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :result

    def init
      self.result = params[:result]
    end

  end

  private

  def authentication_key
    Constants::WELCOME_MESSAGE_AUTH_KEY
  end

  def mobile_numbers
    list = ""
    params[:mobile_number].each do |number|
      list += number.to_s + ","
    end
    return list
  end

end