class ItzCash::SetMccCode < ItzCash::Base

  attr_accessor :selected_card

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
    'itzcash_mcc_group_restriction'
  end

  def init
    super()
    self.selected_card = user.cards.first
  end

  # terminal restriction type and terminal restriction group will be hard coded till ItzCash gets back to us with the terminal group codes
  def post_params
    {serialid: selected_card.proxy, itzmodule: Constants::ItzCash::MODULE,
     terminalrestrictiontype: "I", terminalrestrictiongroup: "NA",
     mccrestrictiontype: params[:mcc_restriction_type], mccrestrictiongroup: MccGroup.code_for(params[:mcc_group_id])}
  end

  def validate
    if MccGroup.code_for(params[:mcc_group_id]).nil? && params[:mcc_restriction_type] == "A"
      add_message :error, "Invalid MCC group code. Please try again"
      return false
    end
  end

  def success
    params[:response_code] = parsed_response[0]
    params[:serial_id] = parsed_response[1]
    params[:description] = parsed_response[2]
    ItzCash::SetMccCode::SuccessPresenter.new(user, params, messages)
  end

  def failure
    super()
  end

  class ItzCash::SetMccCode::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :response_code, :serial_id, :description

    def init
      self.response_code = params[:response_code]
      self.serial_id = params[:serial_id]
      self.description = params[:description]
    end
  end


end