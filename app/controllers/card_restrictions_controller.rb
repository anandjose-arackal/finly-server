class CardRestrictionsController < ApplicationController
  #
  before_action -> { doorkeeper_authorize! :web}

  def create

  end

  def update
    @result = Card::Restriction::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Card::Restriction::Destroy.(current_user, params)
    if @result.success?
      flash[:success] = @result.messages[:success].to_sentence
    else
      flash[:error] = @result.messages[:error].to_sentence
    end
  end
end
