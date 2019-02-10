class Gatekeeper::Rules::SessionsCreate::WebChecks < Gatekeeper::Rules::BaseRule
  index Gatekeeper::Master

  # Web specific checks
  rule '', on: :after_session_create do
    headers = RequestStoreUtil.current_request.headers
    if headers['X-Finly-RP'].blank?
      add_message :error, 'X-Finly-RP has not been set'
      response_code 401
    end
  end

end