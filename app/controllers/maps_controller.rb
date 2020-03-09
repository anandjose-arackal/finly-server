class MapsController < BaseControllers::WebBase

  def auto_complete
    endpoint Maps::AutoComplete do |m|
      m.success {|result| render json: result['model'].result }
    end
  end

  def details
    endpoint Maps::PlaceDetails do |m|
      m.success {|result| render json: result['model'].result }
    end
  end

  def recent_places
    endpoint Maps::RecentPlaces do |m|
      m.success {|result| render json: result['model.index'] }
    end
  end

  def waypoints_distance
    endpoint Maps::WaypointsDistance do |m|
      m.success {|result| render json: {distance: result['distance']} }
    end
  end

end
