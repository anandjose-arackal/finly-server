class ExportPreferencesController < ApplicationController

  before_action :authenticate_user!
  before_action :load_service_objects

  def create
    if @export_service.add_export_field(export_params)
      flash[:success] = "Field added."
    else
      flash[:error] = @export_service.errors
    end
    @export_preferences = current_company.export_preferences
    @export_fields = ExportField.all
    render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
  end

  def destroy
    if @export_service.remove_export_field(id: params[:export_field_id])
      flash[:success] = "Field deleted."
    else
      flash[:error] = @export_service.errors
    end
    @export_preferences = current_company.export_preferences
    @export_fields = ExportField.all
    render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
  end

  def update
    if @export_service.update_export_field(params[:id], export_params)
      flash[:success] = "Field updated."
    else
      flash[:error] = @export_service.errors
    end
    @export_preferences = current_company.export_preferences
    @export_fields = ExportField.all
    render_flash_message
  end

  private

  def export_params
    params.require(:export).permit(:export_field_id, :name)
  end

  def load_service_objects
    @export_service = ExportService.new(current_company)
  end

end
