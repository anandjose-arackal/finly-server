class BankTransfer::PaymentsController < ApplicationController

  before_action {finly_authorize! :web}

  def index
    @result = BankTransfer::Payments::Index.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::Payments::Count.(current_user, params)
    render json: @result.as_json
  end

  def show

  end

  def retry
    @result = BankTransfer::Payments::Retry.(current_user, params)
    respond
  end

  def bulk_upload_utr
    @result = BankTransfer::Payments::BulkUploadUtr.(current_user, params)
    respond
  end

  def payout_index
    @result = BankTransfer::Payments ::PayoutIndex.(current_user, params)
    respond
  end
end