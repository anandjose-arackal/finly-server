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
    'https://staging.itzcash.com/'
  end

  def path
    'user/servlet/NaradaBlockUnblockServlet'
  end

  def post_params
    serial_id = user.cards.first.serial_id
    request_type = self.request_type
    itz_module = Constants::ItzCash::MODULE
    remarks = (params[:remarks] or 'nil') rescue 'nil'
    {serialid: serial_id, requesttype: request_type, itzmodule: itz_module, remarks: remarks}
  end

  def request_type
    Constants::ItzCash::OPERATION_TYPE_BLOCK
  end

  def post_process
    user.cards.first.update_attribute(:active, false)
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

  protected

  # Handle success for -100 as -100 is returned if the card is already blocked
  def success?
    self.process_complete and not has_errors? and not self.timeout and (self.response.status == 200 or self.response.status == -100)
  end

end