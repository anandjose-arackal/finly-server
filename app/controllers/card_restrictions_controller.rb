class CardRestrictionsController < ApplicationController

  def create

  end

  def update
    @result = User::CardRestrictions::Update.(current_user, params)
    if @result.success?
      flash[:success] = @result.messages[:success].to_sentence
    else
      flash[:error] = @result.messages[:error].to_sentence
    end
  end

  def destroy
    @result = User::CardRestrictions::Destroy.(current_user, params)
    if @result.success?
      flash[:success] = @result.messages[:success].to_sentence
    else
      flash[:error] = @result.messages[:error].to_sentence
    end
  end
end
