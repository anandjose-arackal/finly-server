class OrganizationAccountController < ApplicationController

  before_action :authenticate_user!
  before_action :load_service_objects

  def add_category
    category = current_company.categories.build(category_params)
    if category.save
      category.update_attributes(active: true)
      flash[:success] = "Category added."
    else
      flash[:error] = category.errors.full_messages
    end
    @categories = current_company.categories.active
    render partial: 'category_list', replace: "#categoriesList"
  end

  def remove_category
    category = current_company.categories.active.find_by(id: params[:category_id])
    if category and category.update_attributes(active: false)
      flash[:success] = "Category removed."
    elsif category.nil?
      flash[:error] = "Category not found."
    else
      flash[:error] = category.errors.full_messages
    end
    @categories = current_company.categories.active
    render partial: 'category_list', replace: "#categoriesList"
  end

  def show
    load_variables_for_show
  end

  def update_export_column
    if @export_service.update_export_field(params[:id], export_params)
      flash[:success] = "Field updated."
    else
      flash[:error] = @export_service.errors
    end
    @export_preferences = current_company.export_preferences
    @export_fields = ExportField.all
    render partial: 'organization_account/export_preferences', replace: 'exportPreferencesDiv'
    render_flash_message
  end

  def add_export_column
    if @export_service.add_export_field(export_params)
      flash[:success] = "Field added."
    else
      flash[:error] = @export_service.errors
    end
    @export_preferences = current_company.export_preferences
    @export_fields = ExportField.all
    render partial: 'organization_account/export_preferences', replace: 'exportPreferencesDiv'
  end

  def remove_export_column
    if @export_service.remove_export_field(id: params[:export_field_id])
      flash[:success] = "Field deleted."
    else
      flash[:error] = @export_service.errors
    end
    @export_preferences = current_company.export_preferences
    @export_fields = ExportField.all
    render partial: 'organization_account/export_preferences', replace: 'exportPreferencesDiv'
  end


  private

  def category_params
    params.require(:category).permit(:name)
  end

  def export_params
    params.require(:export).permit(:export_field_id, :name)
  end

  def load_variables_for_show
    @categories = current_company.categories.active
    @export_fields = ExportField.all
    @export_preferences = current_company.export_preferences
  end

  def load_service_objects
    @export_service = ExportService.new(current_company)
  end

end
