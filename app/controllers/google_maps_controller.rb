class GoogleMapsController < BaseControllers::WebBase

  def maps_config
    @result = GoogleMaps::Config.(current_user, params)
    respond
  end

end
