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
    if params.blank? or params[:card_id].blank? or user.cards.with_id(params[:card_id].blank?)
      add_message :error, 'Card not found'
      return
    end
  end

  def env_key
    'itzcash_block_unblock'
  end

  def post_params
    serial_id = user.cards.with_id(params[:card_id]).first.id
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

  # def success_response_code
  #   [0, -100]
  # end

  def success
    # ResponseCode,SerialID,Description
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:description]=parsed_response[2]
    ItzCash::Block::SuccessPresenter.new(self.user, params, messages)
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
    success = super
    if not success and parsed_response[0] == '-100' and (self.response.body.include?('The card is already unblocked') or self.response.body.include?('The card is already blocked'))
      success = true
    end
    success
  end

end