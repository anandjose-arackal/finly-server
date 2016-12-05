# operations that invites all the

class WelcomeMessage::Create < BaseHandler


  def pre_validate
    if params.blank? or params[:mobile_number].blank?
      add_message :error, 'Mobile number cannot be blank'
    end
  end

  def env_key
    'msg91_welcome_message'
  end

  def init
    super()
  end

  def process
    # post payload as JSON instead of "www-form-urlencoded" encoding:
    self.response = self.connection.get do |req|
      req.url path
      req.params = {authkey: authentication_key,
                    mobiles: mobile_numbers,
                    message: "You have been invited to use Finly. Please contact your manager to activate your account",
                    sender: "FINLYX",
                    route: 4,
                    country: 91,
                    response: "json"
                    }
    end
  end

  def parse
    # todo - take up once msg91 fixes their end
  end

  def success
    WelcomeMessage::Create::SuccessPresenter.new(user, {result: "Success"})
  end

  class WelcomeMessage::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

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