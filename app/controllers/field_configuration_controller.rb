class FieldConfigurationController < BaseControllers::WebBase


  def index
    @result = FieldCustomization::Show.(current_user, params)
    respond
  end

end
