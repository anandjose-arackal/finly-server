class CategoriesController < ApplicationController

  def create
    category = current_company.categories.build(category_params)
    if category.save
      category.update_attributes(active: true)
      flash[:success] = "Category added."
    else
      flash[:error] = category.errors.full_messages
    end
    @categories = current_company.categories.active
    render partial: 'organization_account/category_list', replace: "#categoriesList"
  end

  def destroy
    category = current_company.categories.active.find_by(id: params[:category_id])
    if category and category.update_attributes(active: false)
      flash[:success] = "Category removed."
    elsif category.nil?
      flash[:error] = "Category not found."
    else
      flash[:error] = category.errors.full_messages
    end
    @categories = current_company.categories.active
    render partial: 'organization_account/category_list', replace: "#categoriesList"
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end


end
