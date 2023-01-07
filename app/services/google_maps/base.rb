class GoogleMaps::Base < ServiceApi

  url "https://maps.googleapis.com/maps/api/"
  parse -> (user, params, response) do
    JSON.parse response.body
  end

  def key
    'AIzaSyCKfnxlnJMj83_nbjDrKFq6RcsPpCMeS7s'
  end

end