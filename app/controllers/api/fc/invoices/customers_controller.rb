class Api::Fc::Invoices::CustomersController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


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
