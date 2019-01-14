class Settlement::ReportController < BaseControllers::WebBase

  set_tokens_in_header :processing_payment_file
  before_action -> { finly_authorize! :web }

  def pending_index
    @result = Settlement::SReport::Pending::Index.(current_user, params)
    respond
  end

  def pending_count
    @result = Settlement::SReport::Pending::Index.(current_user, params)
    respond
  end

  def processing_init
    @result = Settlement::SReport::Processing::Init.(current_user, params)
    respond
  end

  def processing_create
    @result = Settlement::SReport::Processing::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_cancel
    @result = Settlement::SReport::Processing::Cancel.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_mark_paid
    @result = Settlement::SReport::Processing::MarkAsPaid.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def processing_index
    @result = Settlement::SReport::Processing::Index.(current_user, params)
    respond
  end

  def processing_count
    @result = Settlement::SReport::Processing::Index.(current_user, params)
    respond
  end

  def processing_payment_file
    @result = Settlement::SReport::Processing::GeneratePaymentFile.(current_user, params)
    respond
  end

  def completed_index
    @result = Settlement::SReport::Completed::Index.(current_user, params)
    respond
  end

  def completed_count
    @result = Settlement::SReport::Completed::Index.(current_user, params)
    respond
  end

  def completed_batch_index
    @result = Settlement::SReport::Completed::BatchIndex.(current_user, params)
    respond
  end

  def completed_batch_count
    @result = Settlement::SReport::Completed::BatchIndex.(current_user, params)
    respond
  end

end
