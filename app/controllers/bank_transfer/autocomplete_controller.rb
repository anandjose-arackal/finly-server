class BankTransfer::AutocompleteController < ApplicationController

  def user
    @users = User::Team::Index.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end

  def vendors
    @result = BankTransfer::Autocomplete::Vendors.(current_user, params)
    respond_to do |format|
    	format.json {}
    end
  end
end