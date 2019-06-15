class Api::Fc::Invoices::OutwardInvoicesController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


  # this action should create an invoice, as well as update it with the valid details
  def create_valid
    @result = Invoicing::Invoice::CreateValid.(current_user, params)
    respond
  end

end
