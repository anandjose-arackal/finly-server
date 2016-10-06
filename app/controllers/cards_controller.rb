class CardsController < ApplicationController

  #params = {user_id: 1}
  def details
    @result = User::PrepaidCard::Show.(current_user, params)
    # respond
    respond_to do |format|
      format.json { render json: {balance: @result.balance} }
    end
  end

  # params = {action_type: 1, amount: 100, password: 'password'}
  def update_balance
    action_type = params[:action_type].to_i rescue nil
    case action_type
    when 1
      #Credit
      @result = User::PrepaidCard::Credit.(current_user, params)
    when 2
      #Debit
      @result = User::PrepaidCard::Debit.(current_user, params)
    end
  end

  # params = { disable_note: 'why am i disabling this card', action_type: 1, password: 'password' }
  def update_status
    status_type = params[:status_type].to_i rescue nil
    case status_type
      when 0
        # Block
        @result = User::PrepaidCard::Block.(current_user, params)
      when 1
        # Unblock
        @result = User::PrepaidCard::Unblock.(current_user, params)
    end
  end

end
