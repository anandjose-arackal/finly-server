class BankTransfer::VendorTypesController < BaseControllers::WebBase

  def index
    @result = BankTransfer::VendorTypes::Index.(current_user, params)
    respond
  end

  def create
    @result = BankTransfer::VendorTypes::Create.(current_user, params)
    respond
  end

  def update
    @result = BankTransfer::VendorTypes::Update.(current_user, params)
    respond
  end

  def destroy
    @result = BankTransfer::VendorTypes::Destroy.(current_user, params)
  end
end
