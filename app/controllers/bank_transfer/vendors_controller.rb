class BankTransfer::VendorsController < BaseControllers::PublicBase

  def create
    @result = BankTransfer::Vendors::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = BankTransfer::Vendors::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = BankTransfer::Vendors::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def show_transfers
    @result = BankTransfer::Vendors::Transfers::Show.(current_user, params)
    respond
  end

  def import
    @result = BankTransfer::Vendors::Import.(current_user, params)
    respond
  end

  def bank_accounts
    @result = BankTransfer::Vendors::BankAccounts.(current_user, params)
    respond
  end

  def index
    @result = BankTransfer::Vendors::Index.(current_user, params)
    respond
  end

  def new_vendor_config
    @result = BankTransfer::Vendors::NewVendorConfig.(current_user, params)
    respond
  end

  def upload_attachments
    @result = BankTransfer::Vendors::UploadAttachments.(current_user, params)
    respond
  end

  def remove_attachment
    @result = BankTransfer::Vendors::RemoveAttachment.(current_user, params)
    respond
  end

end
