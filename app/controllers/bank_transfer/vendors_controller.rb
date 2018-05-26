class BankTransfer::VendorsController < ApplicationController

  def create
    @result = BankTransfer::Vendors::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = BankTransfer::Vendors::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = BankTransfer::Vendors::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show_transfers
    @result = BankTransfer::Vendors::Transfers::Show.(current_user, params)
    respond
  end

  def import
    @result = BankTransfer::Vendors::Import.(current_user, params)
    respond
  end

  def bank_accounts
    @result = BankTransfer::Vendors::BankAccounts.(current_user, params)
    respond
  end

  def index
    @result = BankTransfer::Vendors::Index.(current_user, params)
    respond
  end

end