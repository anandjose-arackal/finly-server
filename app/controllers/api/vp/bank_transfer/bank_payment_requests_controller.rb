class Api::Vp::BankTransfer::BankPaymentRequestsController < BaseControllers::ApiBase

  protect_from_forgery with: :null_session

  def create
    params[:api_initiated] = true
    # reformat_params
    # debugger
    # @result = BankTransfer::PaymentRequest::Beneficiary::CreateBeneficiaryTicket.(current_user, params)
    @result = BankTransfer::PaymentRequest::Create.(current_user, params)
    if @result.success? and @result.bank_payment_request.present?
      RequestStore.store[:current_app] = :vp # todo jugaad for fixing the reviewer for API requests
      @result = BankTransfer::PaymentRequest::Review::Submit.(current_user, {bank_payment_request_id: @result.bank_payment_request.id})
      RequestStore.store[:current_app] = :api # todo jugaad for fixing the reviewer for API requests
    end
    respond
  end

  def show
    @result = BankTransfer::PaymentRequest::Show.(current_user, params)
    respond
  end

  def credit
    @result = BankTransfer::PaymentRequest::Review::Credit.(current_user, params)
    respond
  end

  def initiate_payment
    @result = BankTransfer::Payments::ApiPayments::InitiatePayment.(current_user, params)
    respond
  end

  def bulk_initiate_payment
    @result = BankTransfer::Payments::ApiPayments::BulkInitiatePayment.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.json { render 'bulk_initiate_success'}
      end
    else
      respond_to do |format|
        format.json { render 'bulk_initiate_failures'}
      end
    end
  end

  # this action will take a particular payment ID and return the status of that particular payment
  def payment_status
    params[:search_type] = 'id'
    @result = BankTransfer::Payments::ApiPayments::GetPaymentStatus.(current_user, params)
    respond
  end

  def payment_status_by_external_ref
    params[:search_type] = 'external_id'
    @result = BankTransfer::Payments::ApiPayments::GetPaymentStatus.(current_user, params)
    respond
  end

  def review
    review_handler(params[:type])
  end

  private

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
