class OrganizationAccountController < ApplicationController

  before_action :authenticate_user!

  def show
    @result = Company::Configuration::Show.new(current_user, params).run
  end

end
