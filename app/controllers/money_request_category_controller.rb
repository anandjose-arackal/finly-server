class MoneyRequestCategoryController < BaseControllers::WebBase


  def create
    @result = MoneyRequest::Category::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = MoneyRequest::Category::Index.(current_user, params)
    respond
  end

  def destroy
    @result = MoneyRequest::Category::Destroy.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
