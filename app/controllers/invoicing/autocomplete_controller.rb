class Invoicing::AutocompleteController < ApplicationController
  def customer
    @result = Invoicing::Customer::Index.(current_user, params)
    respond_to do |format|
      format.json {}
    end
  end
end