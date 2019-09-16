class Api::Fc::Invoices::VirtualBankAccountsController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


  def create
    param = RequestFormatter::VirtualBankAccountParser::Parse.(current_user, params).formatted_request
    @result = Invoicing::VirtualBankAccount::Create.(current_user, param)
    respond
    # if @result.success?
    #   respond response: :success, message: @result.messages[:success]
    # else
    #   respond response: :failure, message: @result.messages[:error]
    # end
  end

  def update
    param = RequestFormatter::VirtualBankAccountParser::Parse.(current_user, params).formatted_request
    @result = Invoicing::VirtualBankAccount::Update.(current_user, param)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def deactivate
    @result = Invoicing::VirtualBankAccount::Deactivate.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = Invoicing::VirtualBankAccount::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Invoicing::VirtualBankAccount::Show.(current_user, params)
    respond
  end

  def index

  end
end
