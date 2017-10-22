class Invoicing::VirtualBankAccountsController < ApplicationController

  def create
    @result = Invoicing::VirtualBankAccount::Create.(current_user, params)
    respond
  end

  def index
    @result = Invoicing::VirtualBankAccount::Index.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::VirtualBankAccount::Destroy.(current_user, params)
    respond
  end

  def deactivate
    @result = Invoicing::VirtualBankAccount::Deactivate.(current_user, params)
    respond
  end

  def reactivate
    @result = Invoicing::VirtualBankAccount::Reactivate.(current_user, params)
    respond
  end
end