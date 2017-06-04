class Api::Fm::V1::CardsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def index
    @result = Card::Index.(current_user, params)
    respond
  end

  def show
    @result = Card::Show.(current_user, params)
    respond
  end

  def transactions
    @result = Card::Transaction::Index.(current_user, params)
    respond
  end

end
