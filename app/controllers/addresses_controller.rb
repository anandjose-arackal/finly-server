class AddressesController < BaseControllers::WebBase

  def index
    @result = Addresses::Index.(current_user, params)
    respond
  end

  def create
    @result = Invoicing::Customer::Addresses::Create.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = Invoicing::Customer::Addresses::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end
