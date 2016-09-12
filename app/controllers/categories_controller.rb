class CategoriesController < ApplicationController

  before_action :authenticate_user!

  def create
    create_op = Company::Category::Create.new(current_user, params)
    @result = create_op.run
    if @result
      flash[:success] = "Category added."
    else
      flash[:error] = create_op.errors
    end
    # authorize Category
    # category = current_company.categories.build(category_params)
    # if category.save
    #   category.update_attributes(active: true)
    #   flash[:success] = "Category added."
    # else
    #   flash[:error] = category.errors.full_messages
    # end
    # @categories = current_company.categories.active
    render partial: 'organization_account/category_list', replace: "#categoriesList"
  end

  def destroy
    destroy_op = Company::Category::Destroy.new(current_user, params)
    @result = destroy_op.run
    if @result
      flash[:success] = "Category destroyed."
    else
      flash[:error] = destroy_op.errors
    end
    # authorize Category
    # category = current_company.categories.active.find_by(id: params[:category_id])
    # if category and category.update_attributes(active: false)
    #   flash[:success] = "Category removed."
    # elsif category.nil?
    #   flash[:error] = "Category not found."
    # else
    #   flash[:error] = category.errors.full_messages
    # end
    render partial: 'organization_account/category_list', replace: "#categoriesList"
  end

end
