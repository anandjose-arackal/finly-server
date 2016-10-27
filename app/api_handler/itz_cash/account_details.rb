class ItzCash::AccountDetails < ItzCash::Base

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless user.cards.present?
      add_message :error, 'A card has not been assigned to the user'
    end
  end

  def env_key
    'itzcash_account_details'
  end

  def post_params
    {serialid: user.cards.first.serial_id, itzmodule: Constants::ItzCash::MODULE}
  end

  def success
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:balance] = parsed_response[2]
    params[:status] = parsed_response[3]
    params[:suspended_status] = parsed_response[4]
    params[:rate_group_id] = parsed_response[5]
    params[:distributor_id] = parsed_response[6]
    params[:charge_code] = parsed_response[7]
    params[:product_code] = parsed_response[8]
    params[:description] = parsed_response[9]
    ItzCash::AccountDetails::SuccessPresenter.new(self.user, self.params, self.messages)
  end

  class ItzCash::AccountDetails::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :serial_id, :balance, :status_code, :suspended_status, :rate_group_id,
                  :distributor_id, :charge_code, :product_code, :description

    def init
      self.response_code =params[:response_code]
      self.serial_id = params[:serial_id]
      self.balance = params[:balance]
      self.status_code = params[:status]
      self.suspended_status = params[:suspended_status]
      self.rate_group_id = params[:rate_group_id]
      self.distributor_id = params[:distributor_id]
      self.charge_code = params[:charge_code]
      self.product_code = params[:product_code]
      self.description = params[:description]
    end

    def status
      if self.status_code.present?
        return Constants::ItzCash::CARD_STATUS_CODE[self.status_code.to_sym]
      end
      nil
    end

  end

end