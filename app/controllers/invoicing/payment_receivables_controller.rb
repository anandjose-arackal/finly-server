class Invoicing::PaymentReceivablesController < ApplicationController

  def index
    @result = Invoicing::PaymentReceivable::Index.(current_user, params)
    respond
  end
end