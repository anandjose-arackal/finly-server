class AddressesController < ApplicationController

  def index
    @result = Addresses::Index.(current_user, params)
    respond
  end
end