class Settlement::MoneyRequestsController < BaseControllers::WebBase

  before_action :set_tokens_in_header, only: [:processing_payment_file]

  def pending_index
    @result = Settlement::SMoneyRequest::Pending::Index.(current_user, params)
    respond
  end

  def pending_count
    @result = Settlement::SMoneyRequest::Pending::Index.(current_user, params)
    respond
  end

  def processing_init
    @result = Settlement::SMoneyRequest::Processing::Init.(current_user, params)
    respond
  end

  def processing_create
    @result = Settlement::SMoneyRequest::Processing::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_cancel
    @result = Settlement::SMoneyRequest::Processing::Cancel.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_mark_paid
    @result = Settlement::SMoneyRequest::Processing::MarkAsPaid.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_index
    @result = Settlement::SMoneyRequest::Processing::Index.(current_user, params)
    respond
  end

  def processing_count
    @result = Settlement::SMoneyRequest::Processing::Index.(current_user, params)
    respond
  end

  def processing_payment_file
    @result = Settlement::SMoneyRequest::Processing::GeneratePaymentFile.(current_user, params)
    respond
  end

  def completed_index
    @result = Settlement::SMoneyRequest::Completed::Index.(current_user, params)
    respond
  end

  def completed_count
    @result = Settlement::SMoneyRequest::Completed::Index.(current_user, params)
    respond
  end

  def completed_batch_index
    @result = Settlement::SMoneyRequest::Completed::BatchIndex.(current_user, params)
    respond
  end

  def completed_batch_count
    @result = Settlement::SMoneyRequest::Completed::BatchIndex.(current_user, params)
    respond
  end
  
end
