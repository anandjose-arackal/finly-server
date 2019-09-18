module Helpers::UserSessionsHelper

  def invalidate_session(status_id, *reason)
    message = reason&.to_sentence
    RequestStoreUtil.current_session&.update(status_id: status_id, message: message)
    RequestStoreUtil.current_session_event&.update(status_id: status_id, message: message)
    RequestStoreUtil.current_token&.update(status_id: status_id, message: message)
    head 401
  end

end