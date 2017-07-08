class ExportPreferencesController < ApplicationController


  before_action :doorkeeper_authorize!

  def create
    create_op = Company::ExportPreferences::Create.new(current_user, params)
    @result = create_op.run
    if @result.success?
      messages = @result.messages
      @result = Company::Configuration::Show.(current_user, params)
      @result.messages = messages
      # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
      respond
    else
      flash[:error] = @result.messages[:error]
      respond
    end
  end

  def destroy
    destroy_op = Company::ExportPreferences::Destroy.new(current_user, params)
    @result = destroy_op.run
    if @result.success?
      messages = @result.messages
      @result = Company::Configuration::Show.(current_user, params)
      @result.messages = messages
      # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
      respond_to do |format|
        format.js {}
        format.json {}
      end
    else
      flash[:error] = @result.messages[:error]
    end
  end

  def update
    update_op = Company::ExportPreferences::Update.new(current_user, params)
    @result = update_op.run
    if @result.success?
      messages = @result.messages
      @result = Company::Configuration::Show.(current_user, params)
      @result.messages = messages
      # render partial: 'organization_account/export_preferences', replace: '#exportPreferencesDiv'
      respond_to do |format|
        format.js {}
        format.json {}
      end
    else
      flash[:error] = @result.messages[:error]
    end
  end

end
