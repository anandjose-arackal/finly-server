class CategoriesController < ApplicationController


  before_action -> { finly_authorize! :web}

  def create
    @result = Company::Configuration::Category::Create.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = Company::Configuration::Category::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @categories = current_company.categories.active rescue []
    respond_to do |format|
      format.json {render json: @categories.as_json(:only => [:id, :name])}
    end
  end
end
