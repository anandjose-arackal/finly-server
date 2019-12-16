class Api::V1::Configuration::CustomFieldsController < BaseControllers::ApiBase
  protect_from_forgery with: :null_session

  rescue_from NotAuthorizedException, with: :null_session

  def create
    @result = CustomField::Configuration::Create.(current_user, params)
    respond
  end

  def index
    @result = CustomField::Configuration::Index.(current_user, params)
    respond
  end

  def show
    @result = CustomField::Configuration::Show.(current_user, params)
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

  def dropdownitem_index
    @result = CustomField::Configuration::DropDownItem::Index.(current_user, params)
  end

  def dropdownitem_create
    @result = CustomField::Configuration::DropDownItem::Add.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def dropdownitem_destroy
    @result = CustomField::Configuration::DropDownItem::Remove.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def dependent_custom_fields
    @result = CustomField::FieldConfigurations::DependentIndex.(current_user, params)
    respond
  end

  def associate_users
    @result = CustomField::Configuration::Users::Add.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  def disassociate_users
    @result = CustomField::Configuration::Users::Remove.(current_user, params)
    respond response: @result&.success? ? :success : :failure
  end

  # this action will return the dependent field configurations given a particular drop down item
  def dependent_field_configurations
    @result = CustomField::Configuration::Index.(current_user, params)
    respond
  end
end