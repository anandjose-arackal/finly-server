class Maps::AutoComplete < Transactions::API

  schema do
    params do
      required(:id).value(:str?, min_size?: 3)
      required(:session_token).filled
    end
  end

  pass Model(MapLocationSearch, :find_by_input)
  step :fetch_results

  def fetch_results(context, params:, current_user:, model:, **)
    return true if model.present?

    result = GoogleMaps::AutoComplete.(params: {
        input: params[:id],
        session_token: params[:session_token]
    }, current_user: current_user)

    # Todo: Return the actual error message
    return on_error context, :base, "Error fetching data" unless result.success?

    parsed_result = result['response.parsed']&.dig('result') || {}
    unless parsed_result['status'] == 'OK'
      return on_error context, :base, "Invalid request"
    end

    context[:model] = MapLocationSearch.new input: params[:id], result: result["response.parsed"]
    unless context[:model].save
      return on_error context, :base, context['model'].errors.full_messages
    end

    true
  end

end