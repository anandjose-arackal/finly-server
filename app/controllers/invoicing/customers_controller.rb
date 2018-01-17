class Invoicing::CustomersController < ApplicationController

  before_action -> { finly_authorize! :web }

  def create
    @result = Invoicing::Customer::Create.(current_user, params)
    respond
  end

  def index
    #todo uncomment after creating customer index operation
    # @result = Invoicing::Customer::Index.(current_user, params)
    # respond
  end

  def update
    @result = Invoicing::Customer::Update.(current_user, params)
    respond
  end

  def destroy
    @result = Invoicing::Customer::Destroy.(current_user, params)
    respond
  end
end