class Gatekeeper::Rules::SessionsCreate::WebChecks < Gatekeeper::Rules::BaseRule
  index Gatekeeper::Master

  # Web specific checks
  rule 'X-Finly-RP has to be set for all web requests', on: :after_session_create do
    headers = RequestStoreUtil.current_request.headers
    next unless RequestStoreUtil.current_session.platform == 'UserSessionWeb'
    next if headers['X-Finly-RP'].present?
    response_code 401
    fail
  end

  [:timestamp, :user_agent, :timezone, :fingerprint,
   :language, :browser, :browser_version,
   :browser_engine, :browser_engine_version,
   :os_name, :os_version].each do |property|
    rule "#{property} is required in X-Finly-RP for all web requests", on: :after_session_create do
      session = RequestStoreUtil.current_session
      next unless session.platform == 'UserSessionWeb'
      web = session.user_session_web
      if web.send(property).blank?
        response_code 401
        fail
      end
    end
  end

end