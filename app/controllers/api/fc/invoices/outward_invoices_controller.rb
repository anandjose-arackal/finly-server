class Api::Fc::Invoices::OutwardInvoicesController < ApplicationController

  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }	

  # this action should create an invoice, as well as update it with the valid details
  def create_valid
    @result = Invoicing::Invoice::CreateValid.(current_user, params)
    respond
  end

end