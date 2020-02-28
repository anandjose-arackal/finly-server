class GoogleMapsController < BaseControllers::WebBase

  def maps_config
    @result = GoogleMapsApi::Config.(current_user, params)
    respond
  end

end
