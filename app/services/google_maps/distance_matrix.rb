class GoogleMaps::AutoComplete < ServiceApi

  schema do
    params do
      required(:way_points).array do
        hash do
          required(:latitude).filled
          required(:longitude).filled
        end
      end
    end
  end

  path "place/autocomplete/json"

  query_params -> (user, params) do
    {
        input: params[:input],
        session_token: params[:session_token],
        key: key
    }
  end

end