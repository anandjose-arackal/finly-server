class Here::DistanceMatrix < ServiceApi

  schema do
    params do
      required(:way_points).array do
        hash do
          required(:latitude).filled
          required(:longitude).filled
        end
      end
    end

    rule :way_points do
      unless value.size >= 2
        key.failure("error. Minimum way points required at 2 to calculate distance")
      end

      if value.size > 8
        key.failure("error. Cannot calculate distance for more than 8 way points")
      end
    end
  end

  url "https://route.ls.hereapi.com/"
  path "routing/7.2/calculateroute.json"

  query_params -> (user, params) do

    query_param = {
        mode: mode,
        apiKey: key
    }
    params[:way_points].each_with_index do |way_point, index|
      query_param["waypoint#{index}"] = "#{way_point[:latitude]},#{way_point[:longitude]}"
    end

    query_param
  end

  parse -> (user, params, response) do
    body = JSON.parse response.body
    distance = nil
    if body&.dig('response', 'route')[0].present?
      distance = body&.dig('response', 'route')[0]&.dig('summary', 'distance')
    end
    {distance: distance, body: body}
  end

  def key
    "pFCIx7LcJV9VmPsJGtPsAkbD9PGu9v9ryvLUSMsDP-g"
  end

  def mode
    "shortest;car;"
  end

end