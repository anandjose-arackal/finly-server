class Sms::Message < ServiceApi

  schema do
    params do
      required(:mobile_number).filled
      required(:message).filled
    end

    rule :mobile_number do
      unless Constants::VALID_MOBILE_NUMBER.match?(value)
        key.failure('is invalid')
      end
    end
  end

  url "https://control.msg91.com"
  path "api/sendhttp.php"
  http_method 'get'
  query_params -> (user, params) do
    {
        authkey: authorization_key,
        mobiles: params[:mobile_number],
        message: params[:message],
        sender: 'FINLYX',
        route: 4,
        country: 91,
        response: 'json'
    }
  end
  matcher(
      Dry::Matcher.new(
          success: Dry::Matcher::Case.new(
              match: -> (options) { true },
              resolve: -> (options) { options }
          )
      )
  )

  def authorization_key
    "126829AkHzInaT57ed5ec4"
  end

end