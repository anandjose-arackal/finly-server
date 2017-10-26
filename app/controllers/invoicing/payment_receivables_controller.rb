class Invoicing::PaymentReceivablesController < ApplicationController

  def index
    @result = Invoicing::PaymentReceivable::Index.(current_user, params)
    respond
  end

  def create
    @result = Invoicing::PaymentReceivable::Create.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::PaymentReceivable::Destroy.(current_user, params)
    respond
  end

  def show_transfers

  end

  def show

  end
end