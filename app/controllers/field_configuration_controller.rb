class FieldConfigurationController < ApplicationController

  before_action -> { finly_authorize! :web }

  def index
    @result = FieldCustomization::Show.(current_user, params)
    respond
  end

end
