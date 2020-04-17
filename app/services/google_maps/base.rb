class GoogleMaps::Base < ServiceApi

  url "https://maps.googleapis.com/maps/api/"
  parse -> (user, params, response) do
    JSON.parse response.body
  end

  def key
    "AIzaSyCedNssy3m7S0j16zER3PbVn7vENxjEDIs"
  end

end