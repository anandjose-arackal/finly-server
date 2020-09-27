class MacrosConnector::Run < ServiceApi

  schema do
    params do
      required(:id).filled
    end
  end

  # url -> (user, params) { Rails.application.config_for(:finly_macros)["outbound"]["base_url"] }
  url -> (user, params) { "https://macros_dev.finly.io" }
  path 'jobs'
  http_method 'post'
  client -> (user, params) do
    Faraday.new(url: fetch(:url)) do |faraday|
      faraday.request :url_encoded
      basic_auth = Rails.application.config_for(:finly_macros)['outbound'].with_indifferent_access
      faraday.use Faraday::Request::BasicAuthentication, basic_auth&.dig(:username), basic_auth&.dig(:password)
      faraday.adapter Faraday.default_adapter
    end
  end
  body -> (user, params) do
    params.merge(current_user: user).as_json
  end
  parse -> (user, params, response) do
    return Failure("Error while initiating request") unless response&.success?
    body = JSON.parse(response.body)
    return Failure(body['message']) unless body['success']

    {success: true}.with_indifferent_access
  end
  matcher :build_matcher

  def self.build_matcher(options, result)
    Dry::Matcher.new(
        success: Dry::Matcher::Case.new(
            match: -> (result) { result['response.parsed']&.dig('success') },
            resolve: -> (result) { result }
        ),
        failure: Dry::Matcher::Case.new(
            match: -> (result) { true },
            resolve: -> (result) { result }
        )
    )
  end


end