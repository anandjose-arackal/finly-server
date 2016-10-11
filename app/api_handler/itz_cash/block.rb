class ItzCash::Block < ItzCash::Base

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if user.cards.blank?
      add_message :error, 'A card has not been assigned to the user'
      return
    end
  end

  def base_url
    'http://demo.itzcash.com/'
  end

  def path
    'myaccount/servlet/ItzCashBlockUnBlockHotListServlet'
  end

  def post_params
    serial_id = user.cards.first.serial_id
    operation_type = operation_type
    blocked_mode = 'I'
    itzmodule = Constants::ItzCash::MODULE
    { serial_id: serial_id, operation_type: operation_type, blocked_mode: blocked_mode, itzmodule: itzmodule }
  end

  def operation_type
    Constants::ItzCash::OPERATION_TYPE_BLOCK
  end

  def post_process
    # todo record the credit in our database
  end

  def success
    # ResponseCode,SerialID,Description
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:description]=parsed_response[2]
    ItzCash::Credit::SuccessPresenter.new(self.user, params, messages)
  end


  class ItzCash::Block::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :serial_id, :description

    def init
      self.response_code = params[:response_code]
      self.serial_id = params[:serial_id]
      self.description = params[:description]
    end

  end

end