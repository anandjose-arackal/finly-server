class CardsController < ApplicationController

  #params = {user_id: 1}
  def details
    @result = User::PrepaidCard::Show.(current_user, params)
    # respond
    respond_to do |format|
      format.json {render json: { balance: @result.balance }}
    end
  end

  def credit

  end

  def debit

  end

end
