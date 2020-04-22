class GoogleMaps::AutoComplete < GoogleMaps::Base

  schema do
    params do
      required(:input).value(:str?, min_size?: 3)
      required(:session_token).filled
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