class CategoriesController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

  def create
    @result = Company::Configuration::Category::Create.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
    # messages = @result.messages
    # if @result.success?
    #   @result = Company::Configuration::Show.(current_user, params)
    #   @result.messages = messages
    # end
    respond
  end

  def destroy
    @result = Company::Configuration::Category::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
    # messages = @result.messages
    # if @result.success?
    #   @result = Company::Configuration::Show.(current_user, params)
    #   @result.messages = messages
    # end
    # # respond
    # respond do |format|
    #   format.js {}
    # end
  end

  def index
    @categories = current_company.categories.active rescue []
    respond
    # respond_to do |format|
    #   format.json {render json: @categories.as_json(:only => [:id, :name])}
    # end
  end
end
