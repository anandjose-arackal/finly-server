class CardRestrictionsController < ApplicationController
  def create

  end

  def update
    @result = User::CardRestrictions::Update.(current_user, params)
  end
end
