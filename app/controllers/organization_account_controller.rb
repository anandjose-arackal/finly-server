class OrganizationAccountController < ApplicationController

  before_action :authenticate_user!

  def show
    @result = Company::Configuration::Show.new(current_user, params).run
    # @categories
    # @export_fields = ExportField.all
    # @export_preferences = current_company.export_preferences
    # @policies = current_company.policies
  end


end
