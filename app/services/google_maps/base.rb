class GoogleMaps::Base < ServiceApi

  url "https://maps.googleapis.com/maps/api/"
  parse -> (user, params, response) do
    JSON.parse response.body
  end

  def key
    'AIzaSyDkuIlJgAkFWEnpC8jTT3XEqpPM1C9Quso'
  end

end