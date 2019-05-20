class CostCentersController < BaseControllers::WebBase

  def create
    @result = CostCenters::Create.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = CostCenters::Index.(current_user, params)
    respond
  end

  def update
    @result = CostCenters::Update.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = CostCenters::Destroy.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end
