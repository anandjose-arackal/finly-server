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
  end

end
