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
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def bulk_destroy
    @result = BankTransfer::VendorTypes::BulkDestroy.(current_user, params)
    respond
  end
end
