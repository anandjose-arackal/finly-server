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

  end

  def show_transfers
    @result = BankTransfer::Vendors::Transfers::Show.(current_user, params)
    respond
  end

end