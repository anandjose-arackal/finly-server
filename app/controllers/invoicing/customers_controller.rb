class Invoicing::CustomersController < ApplicationController

  before_action -> { finly_authorize! :web }

  def create
    @result = Invoicing::Customer::Create.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Invoicing::Customer::Index.(current_user, params)
    respond
    #todo uncomment after creating customer index operation
    # @result = Invoicing::Customer::Index.(current_user, params)
    # respond
  end

  def update
    @result = Invoicing::Customer::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show
    @result = Invoicing::Customer::Show.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::Customer::Destroy.(current_user, params)
    respond
  end

  def virtual_bank_accounts
    @result = Invoicing::Customer::VirtualBankAccounts::Index.(current_user, params)
    respond
  end
end