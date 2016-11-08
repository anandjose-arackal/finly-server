class OrganizationAccountController < ApplicationController

  before_action :authenticate_user!

  def blah
    @result = Company::Configuration::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'policy_list'}
    end
  end

  def categories
    @result = Company::Configuration::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'category_list'}
    end
  end

  def export_preferences
    @result = Company::Configuration::Show.(current_user, params)
    respond_to do |format|
      format.html {render partial: 'export_preferences'}
    end
  end

  def show
    @result = Company::Configuration::Show.(current_user, params)

    respond_to do |format|
      format.html {render 'organization_account/show'}
      format.json {render 'organization_account/show'}
    end
  end

end
