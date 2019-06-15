class ReceiptsController < BaseControllers::WebBase

  set_tokens_in_header :export


  def create
    @result = Receipt::Create.(current_user, params)
    respond response: :success
  end

  def index
    @result = Receipt::Index.(current_user, params)
    respond
  end

  def show
    @result = Receipt::Show.(current_user, params)
    respond
  end

  def update
    @result = Receipt::Update.(current_user, params)
    respond response: :success
  end

  def destroy
    @result = Receipt::Destroy.(current_user, params)
    respond response: :success
  end

  def export
    @result = Receipt::Export.(current_user, params)
    if @result.success?
      respond_to do |format|
        format.zip {
          @result.render self
        }
      end
    else
      # respond_to do |format|
      #   format.zip {
          render json: {success: false}
        # }
      # end
    end
  end

  def enable_transcription
    @result = Receipt::Transcription::Enable.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.message[:error]
    end
  end

  def disable_transcription
    @result = Receipt::Transcription::Disable.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.message[:error]
    end
  end

end
