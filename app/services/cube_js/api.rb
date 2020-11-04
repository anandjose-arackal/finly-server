class CubeJs::Api < ServiceApi

  url -> (user, params) { CubeJs.base_url }
  http_method 'get'
  headers -> (user, params) do
    token = CubeJs.generate_token user, expiry: 2.minutes.from_now.to_i
    {
        Authorization: token
    }
  end

  query_params -> (user, params) do
    params[:q].present? ? {query: params[:q]} : {}
  end

  parse -> (user, params, response) { JSON.parse(response.body) }

  matcher(
      Dry::Matcher.new(
          wait: Dry::Matcher::Case.new(
              match: -> (result) {
                result['response.parsed']&.dig('error').present? and
                    result['response.parsed']&.dig('error') == 'Continue wait'
              },
              resolve: -> (result) { handle_success(result) }
          ),
          error: Dry::Matcher::Case.new(
              match: -> (result) { result['response.parsed']&.dig('error').present? },
              resolve: -> (result) { handle_error(result['response.parsed']) }
          ),
          success: Dry::Matcher::Case.new(
              match: -> (result) { true },
              resolve: -> (result) { handle_success(result) }
          )
      )
  )

  def self.handle_error(parsed_response)
    parsed_response['error'] || 'Unknown error occurred'
  end

  def self.handle_success(result)
    result['response.parsed']
  end

end