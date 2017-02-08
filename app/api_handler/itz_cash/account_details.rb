class ItzCash::AccountDetails < ItzCash::Base
  attr_accessor :card

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

  def init
    super
    self.card = user.cards.first
  end

  def success
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:balance] = parsed_response[2].to_d
    params[:status] = parsed_response[3]
    params[:suspended_status] = parsed_response[4]
    params[:rate_group_id] = parsed_response[5]
    params[:distributor_id] = parsed_response[6]
    params[:charge_code] = parsed_response[7]
    params[:product_code] = parsed_response[8]
    params[:available_card_eligibility] = parsed_response[9].to_d
    params[:description] = parsed_response[10]
    update_card
    params[:card] = card
    ItzCash::AccountDetails::SuccessPresenter.new(self.user, self.params, self.messages)
  end

  class ItzCash::AccountDetails::SuccessPresenter < BaseHandler::BasePresenter::SuccessPresenter
    attr_accessor :response_code, :serial_id, :balance, :status_code, :suspended_status, :rate_group_id,
                  :distributor_id, :charge_code, :product_code, :description, :available_card_eligibility,
                  :card

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
      self.available_card_eligibility = params[:available_card_eligibility]
      self.description = params[:description]
      self.card = params[:card]
    end

    def status
      if self.status_code.present?
        return Constants::ItzCash::CARD_STATUS_CODE[self.status_code.to_sym]
      end
      nil
    end

  end

  protected
  def update_card
    if params[:suspended_status] == 'Y'
      card.update_attribute(:active, false) if card.active
    elsif params[:suspended_status] == 'N'
      card.update_attribute(:active, true) unless card.active
    end
    card.balance = parsed_response[2].to_d
    card.available_card_eligibility = parsed_response[9].to_d
  end

end