class Api::V1::Invoices::VirtualBankAccountsController < ApplicationController

  def create
    param = RequestFormatter::VirtualBankAccountParser::Parse.(current_user, params).formatted_request
    @result = Invoicing::VirtualBankAccount::Create.(current_user, param)
    if @result.success?
      respond response: :success, message: @result.success[:message]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    param = RequestFormatter::VirtualBankAccountParser::Parse.(current_user, params).formatted_request
    @result = Invoicing::VirtualBankAccount::Update.(current_user, param)
    if @result.success?
      respond response: :success, message: @result.success[:message]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = Invoicing::VirtualBankAccount::Destroy.(current_user, param)
    if @result.success?
      respond response: :success, message: @result.success[:message]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Invoicing::VirtualBankAccount::Show.(current_user, param)
    respond
  end

  def index

  end
end