class AdminUsers::Kyc::CompaniesController < ApplicationController


  before_action :doorkeeper_authorize!

  def show
    @result = Admin::KycProcesses::Companies::Show.(current_user, params)
    respond
  end

  def update
    @result = Admin::KycProcesses::Companies::Update.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def review

  end

  def update_status

  end

end
