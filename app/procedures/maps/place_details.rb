class Maps::PlaceDetails < Transactions::API

  schema do
    params do
      required(:id).filled
      required(:session_token).filled
    end
  end

  pass Model(MapLocationDetail, :find_by_place_id)
  step :query_details
  pass :save_recent

  def query_details(context, model:, params:, current_user:, **)
    return true if model.present?
    result = GoogleMaps::PlaceDetails.(
        params: {
            place_id: params[:id],
            session_token: params[:session_token]
        }, current_user: current_user
    )
    unless result.success?
      return on_error context, :base, "Error processing request"
    end

    parsed_result = result['response.parsed']&.dig('result') || {}
    detail = MapLocationDetail.new(
        {
            result: result['response.parsed'],
            address: parsed_result['formatted_address'],
            icon: parsed_result['icon'],
            place_id: parsed_result['place_id'],
            url: parsed_result['url'],
            name: parsed_result['name'],
        }
    )
    unless detail.save
      return on_error context, :base, detail.errors.full_messages
    end

    context[:model] = detail
    true
  end

  def save_recent(context, model:, params:, current_user:, **)
    return true if current_user.map_location_user_queries.reorder(created_at: :desc).limit(5).pluck(:place_id).include?(model.place_id)

    current_user.map_location_user_queries.create place_id: model.place_id, map_location_detail: model, name: model.name, address: model.address
  end

end