class Api::Fc::Invoices::CustomersController < ApplicationController

  protect_from_forgery with: :null_session

  before_action -> { finly_authorize! :api }

  def create
    @result = Invoicing::Customer::Create.(current_user, params)
    respond
  end

  def show
    @result = Invoicing::Customer::Show.(current_user, params)
    respond
  end

  def update
    @result = Invoicing::Customer::Update.(current_user, params)
    respond
  end
end