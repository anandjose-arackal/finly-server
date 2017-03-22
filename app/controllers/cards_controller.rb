class CardsController < ApplicationController
  allow_oauth!

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
    action_type = params[:type] rescue nil
    case action_type
      when 'credit', :credit
        # Value = 1
        @result = User::Wallet::Credit.(current_user, params)
      when 'debit', :debit
        # Value = 2
        @result = User::Wallet::Debit.(current_user, params)
    end
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
    respond response: :success
  end

end