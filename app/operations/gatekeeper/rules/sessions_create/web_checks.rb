class Gatekeeper::Rules::SessionsCreate::WebChecks < Gatekeeper::Rules::BaseRule
  index Gatekeeper::Master

  # Web specific checks
  rule 'X-Finly-RP has to be set for all web requests', on: :after_session_create do
    headers = RequestStoreUtil.current_request.headers
    next if headers['X-Finly-RP'].present?
    response_code 401
    fail
  end

  rule 'Timestamp is required in X-Finly-RP for all web requests', on: :after_session_create do
    session = RequestStoreUtil.current_session
    next unless session.platform == 'UserSessionWeb'
    web = session.user_session_web
    if web.timestamp.blank?
      response_code 401
      fail
    end
  end

end