class Gatekeeper::Rules::SessionsCreate::BasicChecks < Gatekeeper::Rules::BaseRule
  index Gatekeeper::Master

  # Basic Checks
  rule '', on: :after_session_create do

  end
end