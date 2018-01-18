class Invoicing::OutwardInvoicesController < ApplicationController

  def index
    @result = Invoicing::Invoice::Index.(current_user, params)
    respond
  end

  def show
    @result = Invoicing::Invoice::Show.(current_user, params)
    respond
  end

  def create
    @result = Invoicing::Invoice::Create.(current_user, params)
    respond
  end

  # this will save the current draft of the particular outward invoice (without submitting it)
  def update
    @result = Invoicing::Invoice::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy

  end

  def add_customer
    @result = Invoicing::Invoice::Customer::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def remove_customer
    @result = Invoicing::Invoice::Customer::Remove.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_address
    @result = Invoicing::Invoice::Address::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_virtual_account
    @result = Invoicing::Invoice::VirtualAccount::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end