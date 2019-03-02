# class Gatekeeper::Rules::VerifyRequest < Gatekeeper::Rules::BaseRule
#   index Gatekeeper::Master
#
#   rule 'Request IP Address should match session IP', on: :after_finly_authorize do
#     current_ip = RequestStoreUtil.current_request.remote_ip
#     session_ip = RequestStoreUtil.current_session.ip
#     if current_ip != session_ip
#       message 'IP mismatch with session IP'
#       response_code 401
#     end
#   end
#
# end