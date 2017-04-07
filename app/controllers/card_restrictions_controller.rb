class CardRestrictionsController < ApplicationController
  # before_action :authenticate_user!
  allow_oauth!

  def create

  end

  def update
    p "xxxx", current_user
    @result = User::CardRestrictions::Update.(current_user, params)
    respond
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
