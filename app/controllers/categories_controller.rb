class CategoriesController < ApplicationController

  before_action :authenticate_user!

  def create
    @result = Company::Configuration::Category::Create.(current_user, params)
    messages = @result.messages
    if @result.success?
      @result = Company::Configuration::Show.(current_user, params)
      @result.messages = messages
    end
    respond
  end

  def destroy
    @result = Company::Configuration::Category::Destroy.(current_user, params)
    messages = @result.messages
    if @result.success?
      @result = Company::Configuration::Show.(current_user, params)
      @result.messages = messages
    end
    # respond
    respond do |format|
      format.js {}
    end
  end

end
