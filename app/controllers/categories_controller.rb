class CategoriesController < BaseControllers::WebBase


  def create
    @result = Categories::Create.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update
    @result = Categories::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = Categories::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Categories::Index.(current_user, params)
    respond
  end

  def sub_categories
    @result = Categories::SubCategories::Index.(current_user, params)
    respond
  end
end
