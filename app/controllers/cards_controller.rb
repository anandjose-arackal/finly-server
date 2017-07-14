class CardsController < ApplicationController


  before_action -> { doorkeeper_authorize! :web}

  # params = {user_id: 1}
  def details
    @result = User::PrepaidCard::Show.(current_user, params)
    # respond
    if @result.failure?
      respond response: :failure
      return
    end
    respond_to do |format|
      format.json { render json: {balance: @result.balance} }
    end
  end

  # params = {action_type: 1, amount: 100, password: 'password', from_account: :virtual_account/:wallet/:card,
  # :to_account: :virtual_account/:wallet/:card }
  def update_balance
    action_type = params[:type] || params[:action_type] rescue nil
    case action_type
      when 'credit', :credit
        # Value = 1
        @result = User::Wallet::Credit.(current_user, params)
      when 'debit', :debit
        # Value = 2
        @result = User::Wallet::Debit.(current_user, params)
    end
    respond
  end

  # params = { disable_note: 'why am i disabling this card', action_type: 1, password: 'password' }
  def update_status
    status_type = params[:status_type].to_i rescue nil
    case status_type
      when User::PrepaidCard::Base::STATUS[:block]
        # Block = 0
        @result = User::PrepaidCard::Block.(current_user, params)
      when User::PrepaidCard::Base::STATUS[:unblock]
        # Unblock = 1
        @result = User::PrepaidCard::Unblock.(current_user, params)
    end
    respond
  end

  # For Mass Crediting accounts
  def process_file
    @result = Benefits::TaxBenefits::ParseFile.(config, current_user, params)
    respond
  end

  def assign
    # @result = Card::Assign.(current_user, params)
    @result = Card::AssignRequest::Create.(current_user, params)
    respond
  end

  def cancel_assign
    # @result = Card::Assign.(current_user, params)
    @result = Card::AssignRequest::Cancel.(current_user, params)
    respond
  end

  def unassigned
    @result = Card::Unassigned.(current_user, params)
    respond
  end



end