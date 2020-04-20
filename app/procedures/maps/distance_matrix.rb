class Maps::DistanceMatrix < Transactions::API

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

  pass :query_here

  def query_here(context, params:, current_user:, **)
    result = Here::DistanceMatrix.(params: params, current_user: current_user)
    unless result.success?
      return on_error(context, :base, "Error in request")
    end

    context[:distance] = result['response.parsed']&.dig(:distance)
  end

end