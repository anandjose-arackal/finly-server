class Api::V1::PrepaidCardsController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def show
    @result = User::PrepaidCard::Show.(current_user, params)
    respond
  end

  def transactions

  end

  def assign

  end

  def fund

  end

  def status

  end

  def restrictions

  end

  def request

  end

end
