class OrganizationAccountController < ApplicationController

  before_action :authenticate_user!

  def show
    @result = Company::Configuration::Show.new(current_user, params).run

    respond_to do |format|
      format.html {render 'organization_account/show'}
      format.json {render 'organization_account/show'}
    end
  end

end
