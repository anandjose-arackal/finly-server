class Api::Vp::V1::InwardInvoiceAttachmentsController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session


  def create
    @result = BankTransfer::InvoiceAttachments::Create.(current_user, params)
    respond
  end

  def index
    @result = BankTransfer::InvoiceAttachments::Index.(current_user, params)
    respond
  end

  def destroy
    @result = BankTransfer::InvoiceAttachments::Destroy.(current_user, params)
    respond_success_failure
  end

end
