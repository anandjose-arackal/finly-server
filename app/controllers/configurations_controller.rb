class ConfigurationsController < WebBase

  def loc_dept
    @result = Configs::LocDept.(current_user, params)
    respond
  end

end
