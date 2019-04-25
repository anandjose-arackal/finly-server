class MoneyRequestCategoryController < ApplicationController

  before_action -> { finly_authorize! :web}

  def create
    @result = MoneyRequests::Category::Create.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = MoneyRequests::Category::Index.(current_user, params)
    respond
  end

  def destroy
    @result = MoneyRequests::Category::Destroy.(current_user, params)
    respond response: (@result&.success? ? :success : :failure)
  end

end
