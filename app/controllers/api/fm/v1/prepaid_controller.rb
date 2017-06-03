class Api::Fm::V1::PrepaidController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def index
    @result = Card::Index.(current_user, params)
    respond
  end

  def show
    @result = User::PrepaidCard::Show.(current_user, params)
    respond
  end

end
