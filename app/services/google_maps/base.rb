class GoogleMaps::Base < ServiceApi

  url "https://maps.googleapis.com/maps/api/"
  parse -> (user, params, response) do
    JSON.parse response.body
  end

  def key
    'AIzaSyDCkJlv14t76ikb1Jg4a1M6Z09dxYuOSXk'
  end

end