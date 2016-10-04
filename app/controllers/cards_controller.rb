class CardsController < ApplicationController

  #params = {user_id: 1}
  def details
    @result = User::PrepaidCard::Show.(user, params)
    respond
  end

  def credit

  end

  def debit

  end

end
