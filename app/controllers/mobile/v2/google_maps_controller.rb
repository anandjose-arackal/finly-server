class Mobile::V2::GoogleMapsController < BaseControllers::MobileBase

  def maps_config
    @result = GoogleMaps::Config.(current_user, params)
    respond
  end

end
