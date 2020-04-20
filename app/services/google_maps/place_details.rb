class GoogleMaps::PlaceDetails < GoogleMaps::Base

  schema do
    params do
      required(:place_id).filled
      required(:session_token).filled
    end
  end

  path "place/details/json"

  query_params -> (user, params) do
    {
        place_id: params[:place_id],
        session_token: params[:session_token],
        key: key,
        fields: "address_component,adr_address,formatted_address,geometry,icon,name,permanently_closed,photo,place_id,plus_code,type,url,utc_offset,vicinity"
    }
  end

end