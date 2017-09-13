class ItzCash::AccountDetailsYse < ItzCash::AccountDetails
  attr_accessor :card

  def env_key
    'itzcash_account_details_yse'
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
    # This is from YSE's system to track if card is locked or not. Possible values given in CONSTANTS
    params[:card_processor_status] = parsed_response[10]
    params[:description] = parsed_response[12]
    update_card
    params[:card] = card
    ItzCash::AccountDetails::SuccessPresenter.new(self.user, self.params, self.messages)
  end

  protected
  def update_card
    super
    card.update(card_processor_status: params[:card_processor_status])
  end

end