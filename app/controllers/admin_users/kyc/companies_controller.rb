class AdminUsers::Kyc::CompaniesController < ApplicationController

  before_action :authenticate_user!
  allow_oauth!

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

  # action that sends the relevant documents to ItzCash when pressed from the admin panel
  def send_to_itzcash
    @result = Admin::KycProcesses::Companies::SendToItzcash.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  # action that rejects a particular user's KYC documents for failing the first screening after
  # admin panel verification
  def reject
    @result = Admin::KycProcesses::Companies::Reject.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def confirm
    @result = Admin::KycProcesses::Companies::Confirm.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

end
