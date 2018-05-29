class BankTransfer::InwardInvoicesController < ApplicationController

  before_action {finly_authorize! :web}

  def index
    @result = BankTransfer::InwardInvoices::Index.(current_user, params)
    respond
  end

  def show
    @result = BankTransfer::InwardInvoices::Show.(current_user, params)
    respond
  end

  def create
    @result = BankTransfer::InwardInvoices::Create.(current_user, params)
    respond_success_failure
  end

  def update
    @result = BankTransfer::InwardInvoices::Update.(current_user, params)
    respond_success_failure
  end

  def destroy
    @result = BankTransfer::InwardInvoices::Destroy.(current_user, params)
    respond_success_failure
  end

  def create_payment
    @result = BankTransfer::InwardInvoices::Payments::Create.(current_user, params)
    respond
  end

  def show_payments
    @result = BankTransfer::InwardInvoices::Payments::Create.(current_user, params)
    respond
  end

end