class CustomFieldsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def create
    @result = CustomField::Configuration::Create.(current_user, params)
      respond response: @result&.success? ? :success : :failure
  end

  def index
    @result = CustomField::Configuration::Index.(current_user, params)
    respond
  end

  def update
    @result = CustomField::Configuration::Update.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def destroy
    @result = CustomField::Configuration::Destroy.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def dropdownitem_create

  end

  def dropdownitem_destroy

  end

end
