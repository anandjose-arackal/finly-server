class OrganizationAccountController < ApplicationController

  before_action :authenticate_user!

  def show
    @categories = current_company.categories.active
    @export_fields = ExportField.all
    @export_preferences = current_company.export_preferences
  end

  private


end
