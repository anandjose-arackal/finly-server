class ConfigurationsController < ApplicationController

  before_action -> { finly_authorize! :web }

  def loc_dept
    @result = Configs::LocDept.(current_user, params)
    respond
  end

end
