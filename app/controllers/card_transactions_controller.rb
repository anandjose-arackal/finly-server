class CardTransactionsController < ApplicationController

  before_action :authenticate_user!

  allow_oauth!

  def index
    @result = Card::Transaction::Index.(current_user, params)
    respond
  end

  def create

  end

end