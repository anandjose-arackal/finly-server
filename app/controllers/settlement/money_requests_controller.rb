class Settlement::MoneyRequestsController < BaseControllers::WebBase

  before_action :set_tokens_in_header, only: [:processing_payment_file]

  def pending_index
    @result = Settlement::SMoneyRequests::Pending::Index.(current_user, params)
    respond
  end

  def pending_count
    @result = Settlement::SMoneyRequests::Pending::Index.(current_user, params)
    respond
  end

  def processing_init
    @result = Settlement::SMoneyRequests::Processing::Init.(current_user, params)
    respond
  end

  def processing_create
    @result = Settlement::SMoneyRequests::Processing::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_cancel
    @result = Settlement::SMoneyRequests::Processing::Cancel.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_mark_paid
    @result = Settlement::SMoneyRequests::Processing::MarkAsPaid.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_index
    @result = Settlement::SMoneyRequests::Processing::Index.(current_user, params)
    respond
  end

  def processing_count
    @result = Settlement::SMoneyRequests::Processing::Index.(current_user, params)
    respond
  end

  def processing_payment_file
    @result = Settlement::SMoneyRequests::Processing::GeneratePaymentFile.(current_user, params)
    respond
  end

  def completed_index
    @result = Settlement::SMoneyRequests::Completed::Index.(current_user, params)
    respond
  end

  def completed_count
    @result = Settlement::SMoneyRequests::Completed::Index.(current_user, params)
    respond
  end

  def completed_batch_index
    @result = Settlement::SMoneyRequests::Completed::BatchIndex.(current_user, params)
    respond
  end

  def completed_batch_count
    @result = Settlement::SMoneyRequests::Completed::BatchIndex.(current_user, params)
    respond
  end
  
end
