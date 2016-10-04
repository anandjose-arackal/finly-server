class CardsController < ApplicationController

  #params = {user_id: 1}
  def details
    @result = User::PrepaidCard::Show.(user, params)
    respond
  end

  # params = {action_type: 1, amount: 100, password: 'password'}
  def update_balance
    action_type = params[:action_type].i rescue nil
    case action_type
      when 1
        #Credit
        User::PrepaidCard::Credit.(current_user, params)
      when 2
        #Debit
        User::PrepaidCard::Debit.(current_user, params)
    end
    respond
  end

  def update_status
    
  end

end
