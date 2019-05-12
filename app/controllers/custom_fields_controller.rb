class CustomFieldsController < BaseControllers::WebBase


  def create
    @result = CustomField::Configuration::Create.(current_user, params)
    respond response: @result&.success? ? :success : :failure
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

end
