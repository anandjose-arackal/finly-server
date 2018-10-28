class BankTransfer::BankPaymentRequestsController < ApplicationController

  before_action :set_tokens_in_header, only: [:download_pending_attachment, :download_selected_attachment, :download_all_attachment]
  before_action {finly_authorize! :web}

  def show
    @result = BankTransfer::PaymentRequest::Show.(current_user, params)
    respond
  end

  def create
    @result = BankTransfer::PaymentRequest::Create.(current_user, params)
    respond
  end

  def index
    @result = BankTransfer::PaymentRequest::Index.(current_user, params)
    respond
  end

  def process_file
    @result = BankTransfer::PaymentRequest::BulkCreateFromFile.(current_user, params)
    # @result = BankTransfer::PaymentRequest::ParseFile.(current_user, params)
    # respond
  end

  def update
    update_handler(params[:type])
  end

  def process_account_ids
    @result = BankTransfer::PaymentRequest::ProcessFromAccountIds.(current_user, params)
    if @result&.success?
      render 'process_account_ids'
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def account_details
    @result = BankTransfer::PaymentRequest::AccountDetails.(current_user, params)
    respond
  end

  def destroy
    @result = BankTransfer::PaymentRequest::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: "Payment order successfully deleted"
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_details
    @result = BankTransfer::PaymentRequest::Update.(current_user, params)
    respond
  end

  def review
    review_handler(params[:type])
  end

  def comment
    @result = BankTransfer::PaymentRequest::Comment::Create.(current_user, params)
    respond
  end

  def credit
    @result = BankTransfer::PaymentRequest::Review::Credit.(current_user, params)
    respond
  end

  def mark_as_credited
    @result = BankTransfer::PaymentRequest::Review::MarkAsCredited.(current_user, params)
    respond
  end

  def count
    @result = BankTransfer::PaymentRequest::Count.(current_user, params)
    render json: @result.as_json
  end

  def add_beneficiary
    @result = BankTransfer::PaymentRequest::Beneficiary::Add.(current_user, params)
    respond
  end

  def remove_beneficiary
    @result = BankTransfer::PaymentRequest::Beneficiary::Remove.(current_user, params)
    respond
  end

  def retry
    @result = BankTransfer::PaymentRequest::Retry.(current_user, params)
    respond
  end

  def within_timeframe
    @result = BankTransfer::Configuration::TransferTimings.(current_user, params)
    respond
  end

  def update_payment
    @result = BankTransfer::PaymentRequest::Payment::Update.(current_user, params)
    respond
  end

  def payment_file
    @result = BankTransfer::PaymentRequest::GeneratePaymentFile.(current_user, params)
    respond
  end

  def bulk_approve_validate
    @result = BankTransfer::PaymentRequest::Review::BulkApproveValidate.(current_user, params)
    respond
  end

  def bulk_approve
    @result = BankTransfer::PaymentRequest::Review::BulkApprove.(current_user, params)
    respond
  end

  def mark_all_pending
    @result = BankTransfer::PaymentRequest::Review::ApproveAllPending.(current_user, params)
    respond
  end

  def download_pending
    @result = BankTransfer::PaymentRequest::Spreadsheet::DownloadPending.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def download_pending_attachment
    @result = BankTransfer::PaymentRequest::Spreadsheet::DownloadPendingAttachment.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def download_selected
    @result = BankTransfer::PaymentRequest::Spreadsheet::DownloadSelected.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def download_selected_attachment
    @result = BankTransfer::PaymentRequest::Spreadsheet::DownloadSelectedAttachment.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def download_all
    @result = BankTransfer::PaymentRequest::Spreadsheet::DownloadAll.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def download_all_attachment
    @result = BankTransfer::PaymentRequest::Spreadsheet::DownloadAllAttachment.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index_configurations
    custom_field_op = CustomField::Configuration::Index.(current_user, {filter_field_type_id: [FieldType.id_for(:drop_down), FieldType.id_for(:multiselect)], filter_parent_type_id: [FieldParentType.id_for(:invoice)]})
    @field_configurations = custom_field_op.field_configurations
    @policies = current_company.vendor_payment_policies
    respond_to do |format|
      format.json {}
    end
  end

  def bulk_credit_validate
    @result = BankTransfer::PaymentRequest::Review::BulkCreditValidate.(current_user, params)
    respond
  end

  def bulk_credit
    @result = BankTransfer::PaymentRequest::Review::BulkCredit.(current_user, params)
    respond
  end

  def sample_import_file
    @result = BankTransfer::PaymentRequest::GenerateImportSample.(current_user, params)
    respond
  end

  def payments_list
    @result = BankTransfer::PaymentRequest::Payments.(current_user, params)
    respond
  end

  def payments_count
    @result = BankTransfer::PaymentRequest::PaymentsCount.(current_user, params)
    render json: @result.as_json
  end

  def add_invoice
    @result = BankTransfer::PaymentRequest::InwardInvoice::Add.(current_user, params)
    respond_success_failure
  end

  private

  def update_handler(type)
    if type.nil?
      respond response: :failure, message: "Invalid request"
      return
    end
    operation = nil
    # success_message = nil
    case type
      when 1, '1'
        # i.e. update of summary
        operation = BankTransfer::PaymentRequest::Update::UpdateSummary.new(current_user, params)
      when 2, '2'
        # i.e. update of payment items
        operation = BankTransfer::PaymentRequest::Update::UpdatePayments.new(current_user, params)
      when 3, '3'
        # i.e. update of attachments
        operation = BankTransfer::PaymentRequest::Update::UpdateAttachment.new(current_user, params)
      else
        # do nothing?
    end
    if operation.blank?
      respond response: :failure, message: "Invalid update type"
      return
    end
    @result = operation.run
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error] || 'Error while updating details'
    end
  end

  def review_handler(type)
    # unless type.present?
    #   respond response: :failure, message: "Invalid request"
    #   return
    # end
    operation = nil
    case type
      when 1, '1'
        # i.e. approve
        operation = BankTransfer::PaymentRequest::Review::Approve.new(current_user, params)
      when 2, '2'
        # i.e. submit
        operation = BankTransfer::PaymentRequest::Review::Submit.new(current_user, params)
      when 3, '3'
        # i.e. retract
        operation = BankTransfer::PaymentRequest::Review::Retract.new(current_user, params)
      when 4, '4'
        # i.e. reject
        operation = BankTransfer::PaymentRequest::Review::Reject.new(current_user, params)
      when 5, '5'
        # i.e. unapprove
        operation = BankTransfer::PaymentRequest::Review::Unapprove.new(current_user, params)
      when 6, '6'
        # i.e. take control
        operation = BankTransfer::PaymentRequest::Review::TakeControl.new(current_user, params)
      when 7, '7'
        # approve and forward
        operation = BankTransfer::PaymentRequest::Review::ApproveAndForward.new(current_user, params)
      when 8, '8'
        # approve and forward
        operation = BankTransfer::PaymentRequest::Review::ReturnControl.new(current_user, params)
      else
        # do nothing?
    end
    if operation.blank?
      respond response: :failure, message: "Invalid update type"
      return
    end
    @result = operation.run
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error] || 'Error while updating details'
    end
  end
end

