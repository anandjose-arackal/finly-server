class MapsController < BaseControllers::WebBase

  def auto_complete
    endpoint Maps::AutoComplete
  end

  def details
    endpoint Maps::PlaceDetails
  end

  def recent_places
    endpoint Maps::RecentPlaces
  end

  def distance_matrix
    endpoint Maps::DistanceMatrix
  end

end
