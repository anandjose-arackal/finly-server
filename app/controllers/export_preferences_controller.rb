class ExportPreferencesController < ApplicationController

  before_action :authenticate_user!

  def create
    create_op = Export::Field::Create.new(current_user, params)
    @result = create_op.run
    if @result.success?
      @result = Company::Configuration::Show.new(current_user, params).run
      # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
      respond_to do |format|
        format.js {}
      end
    else
      flash[:error] = @result.messages[:error]
    end

    # if @export_service.add_export_field(export_params)
    #   flash[:success] = "Field added."
    # else
    #   flash[:error] = @export_service.errors
    # end
    # @result = Company::Configuration::Show.new(current_user, params).run
    # # @export_preferences = current_company.export_preferences
    # # @export_fields = ExportField.all
    # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
  end

  def destroy
    destroy_op = Export::Field::Destroy.new(current_user, params)
    @result = destroy_op.run
    if @result.success?
      @result = Company::Configuration::Show.new(current_user, params).run
      # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
      respond_to do |format|
        format.js {}
      end
    else
      flash[:error] = @result.messages[:error]
    end

    # if @export_service.remove_export_field(id: params[:export_field_id])
    #   flash[:success] = "Field deleted."
    # else
    #   flash[:error] = @export_service.errors
    # end
    # @result = Company::Configuration::Show.new(current_user, params).run
    # # @export_preferences = current_company.export_preferences
    # # @export_fields = ExportField.all
    # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
  end

  def update
    destroy_op = Export::Field::Update.new(current_user, params)
    @result = destroy_op.run
    if @result.success?
      @result = Company::Configuration::Show.new(current_user, params).run
      # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
      respond_to do |format|
        format.js {}
      end
    else
      flash[:error] = @result.messages[:error]
    end

    # if @export_service.update_export_field(params[:id], export_params)
    #   flash[:success] = "Field updated."
    # else
    #   flash[:error] = @export_service.errors
    # end
    # @result = Company::Configuration::Show.new(current_user, params).run
    # # @export_preferences = current_company.export_preferences
    # # @export_fields = ExportField.all
    # render_flash_message
  end

  # private
  #
  # def export_params
  #   params.require(:export).permit(:export_field_id, :name)
  # end
  #
  # def load_service_objects
  #   @export_service = ExportService.new(current_company)
  # end

end
