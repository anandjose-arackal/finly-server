class Api::V1::Invoices::VirtualBankAccountsController < ApplicationController

  def create
    param = RequestFormatter::VirtualBankAccountParser::Parse.(current_user, params).formatted_request
    @result = Invoicing::VirtualBankAccount::Create.(current_user, param)
    if @result.success?
      respond response: :success,
    end
  end

  def update

  end

  def destroy

  end

  def show

  end

  def index

  end
end