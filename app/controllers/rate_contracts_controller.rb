class RateContractsController < ApplicationController

  def index
    @result = RateContracts::Index.(current_user, params)
    respond
  end

  def show
    @result = RateContracts::Show.(current_user, params)
    respond
  end

  def create
    @result = RateContracts::Create.(current_user, params)
    respond
  end

  def update
    @result = RateContracts::Update.(current_user, params)
    respond
  end

  def destroy
    @result = RateContracts::Destroy.(current_user, params)
    respond
  end

  def configuration
    @result = RateContracts::Configuration::Show.(current_user, params)
    respond
  end

  # def upload_attachments
  #   # @result = RateContracts::UploadAttachments.(current_user, params)
  #   # respond
  # end

  # def destroy_attachments
  #   # @result = RateContracts.UploadAttachments.(current_user, params)
  #   # respond
  # end
end
