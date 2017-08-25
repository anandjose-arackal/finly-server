class BankTransfer::BankPaymentRequestsController < ApplicationController

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

  def parse_file
    @result = BankTransfer::PaymentRequest::ParseFile.(current_user, params)
    respond
  end

  def process
    @result = BankTransfer::PaymentRequest::Process.(current_user, params)
    respond
  end

  def update
    update_handler(params[:type])
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
      when 1
        # i.e. update of summary
        operation = BankTransfer::PaymentRequest::Update::UpdateSummary.new(current_user, params)
      when 2
        # i.e. update of payment items
        operation = operation = BankTransfer::PaymentRequest::Update::UpdatePayments.new(current_user, params)
      when 3
        # i.e. update of attachments
        operation = BankTransfer::PaymentRequest::Update::UpdateAttachment.new(current_user, params)
      else
        # do nothing?
    end
    unless operation.present?
      respond response: :failure, message: "Invalid update type"
    end
    @result = operation.run
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error] || 'Error while updating details'
    end
  end
end

