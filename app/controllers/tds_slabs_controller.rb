class TdsSlabsController < BaseControllers::WebBase

  def create
    @result = TdsSlabs::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = TdsSlabs::Index.(current_user, params)
    respond
  end

  def destroy
    @result = TdsSlabs::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = TdsSlabs::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end
