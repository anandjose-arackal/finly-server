class Settlement::ReportController < BaseControllers::WebBase

  set_tokens_in_header :processing_payment_file

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

  def processing_show
    @result = Settlement::SReport::Processing::Show.(current_user, params)
    respond
  end

  def processing_show_items
    @result = Settlement::SReport::Processing::Show.(current_user, params)
    respond
  end

  def processing_update
    @result = Settlement::SReport::Processing::Update.(current_user, params)
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

  # generates excel to gather UTR from user in bulk and process those report batches marked as outside finly
  def generate_template_file
    @result = Settlement::SReport::Processing::GenerateTemplateFile.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.json {}
      end
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  # used to process uploaded template file to process report batches marked as outside finly
  def process_template_file
    @result = Settlement::SReport::Processing::ProcessTemplateFile.(current_user, params)
    if @result.success?
      respond
    else
      render file: 'settlement/money_requests/process_template_file'
    end
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

  def completed_show
    @result = Settlement::SReport::Completed::Show.(current_user, params)
    respond
  end

  def completed_show_items
    @result = Settlement::SReport::Completed::Show.(current_user, params)
    respond
  end

  def completed_batch_count
    @result = Settlement::SReport::Completed::BatchIndex.(current_user, params)
    respond
  end

end
