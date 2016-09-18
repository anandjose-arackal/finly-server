class CategoriesController < ApplicationController

  before_action :authenticate_user!

  def create
    create_op = Company::Configuration::Category::Create.new(current_user, params)
    @result = create_op.run
    if @result.success?
      @result = Company::Configuration::Show.new(current_user, params).run
      respond_to do |format|
        format.js {}
      end
      # render partial: 'organization_account/category_list', replace: "#categoriesList"
    else
      flash[:error] = @result.messages[:error]
    end
  end

  def destroy
    destroy_op = Company::Configuration::Category::Destroy.new(current_user, params)
    @result = destroy_op.run
    if @result.success?
      @result = Company::Configuration::Show.new(current_user, params).run
      respond_to do |format|
        format.js {}
      end
      # render partial: 'organization_account/category_list', replace: "#categoriesList"
    else
      flash[:error] = @result.messages[:error]
    end
  end

end
