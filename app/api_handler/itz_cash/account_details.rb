class ItzCash::AccountDetails < ItzCash::Base
  attr_accessor :card

  def pre_validate
    if params[:card].blank?
      add_message :error, 'Card not found'
    end
  end

  def env_key
    'itzcash_account_details_yse'
  end

  def post_params
    {serialid: card.serial_id, itzmodule: Constants::ItzCash::MODULE}
  end

  def init
    super
    self.card = params[:card]
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
    params[:card_processor_status] = parsed_response[10] # This is from YSE's system to track if card is locked or not. Possible values
    params[:description] = parsed_response[12]
    params[:card] = card
    # special condition because of ItzCash's drama about reissued cards
    if card.replaced_card_id.present?
      replaced_card = Card.unscoped.find_by(id: card.replaced_card_id)
      op = ItzCash::AccountDetails.(replaced_card.user, card: replaced_card)
      if op.success?
        params[:balance] = op.balance
        params[:available_card_eligibility] = op.available_card_eligibility
        params[:distributor_id] = op.distributor_id
      end
    end
    update_card
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

    def assigned?
      if distributor_id == card.user&.company.d_code
        return true
      end
      false
    end

    def upgraded?
      return false unless assigned?
      bal = (self.balance or 0)
      eligibility = (self.available_card_eligibility or 0)
      (bal + eligibility) > 25000
    end

  end

  def success_response_code
    [0, -513]
  end

  protected
  def update_card
    update_assign_status
    update_processor_status
    update_suspend_status
    update_balances
  end

  # This checks if a card has in assigned or upgraded
  def update_assign_status
    status = :unassigned
    if card.user_id.present?
      status = :assign_requested
      unless params[:distributor_id] == "D000000000" || params[:distributor_id] == "NA"
        status = :assigned
        balance = (params[:balance] or 0)
        eligibility = (params[:available_card_eligibility] or 0)
        if balance + eligibility > 21000
          status = :upgraded
        elsif KycStatus.ids_for([:submitted, :processing, :approved, :completed]).include?(card.user.individual_kyc.kyc_status_id)
          status = :upgrade_requested
        end
      end
    end
    status_id = CardStatus.id_for(status)
    unless card.card_status_id == status_id
      card.update(card_status_id: status_id)
    end
    if status == :upgraded and card.user.individual_kyc.kyc_status_id != KycStatus.id_for(:completed)
      card.user.individual_kyc.update(kyc_status_id: KycStatus.id_for(:completed), review_position: nil)
    end

    assign_request = card.card_assign_requests.with_card_owner_id(card.user_id)&.first
    if assign_request.present? and CardAssignRequestStatus.ids_for([:processing, :approved, :rejected, :cancelled]).include? assign_request.status_id
      if [:upgraded].include? status
        assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:assigned_and_upgraded), assigned_by_resource: nil, assigned_on: DateTime.now)
      elsif [:assigned, :upgrade_requested].include? status
        assign_request.update(review_position: nil, status_id: CardAssignRequestStatus.id_for(:assigned), assigned_by_resource: nil, assigned_on: DateTime.now)
      end
    end
  end

  # This checks if a card has in blocked at itzcash or at YSE
  def update_suspend_status
    update_params = {}
    if params[:suspended_status] == 'Y'
      # attributes_to_update[:active] = false if card.active
      update_params[:active] = false if card.active
    elsif params[:suspended_status] == 'N'
      # attributes_to_update[:active] = true if card.active
      update_params[:active] = true unless card.active
    end
    card.update update_params if update_params.present?
  end

  # This sets the balances in the card
  def update_balances
    if card.card_balance.blank?
      id = Amount.create(value: 0, currency_id: Currency.first.id).id
      card.update_attributes(card_balance_id: id)
    end
    if card.card_eligibility.blank?
      id = Amount.create(value: 0, currency_id: Currency.first.id).id
      card.update_attributes(card_eligibility_id: id)
    end
    card.card_balance.update_attributes(value: params[:balance])
    card.card_eligibility.update_attributes(value: params[:available_card_eligibility])
  end

  def update_processor_status
    card.update(card_processor_status: params[:card_processor_status])
  end

end