Gatekeeper::Checker.new 'On New Request' do

  before do
    skip unless RequestStoreUtil.current_session&.client_type == 'UserDeviceBrowser'
  end

  premise :on_authenticated_request do
    rule 'Request IP has to match Session IP' do
      request = RequestStoreUtil.current_request
      session = RequestStoreUtil.current_session
      unless request.ip == session.ip
        update_attr = {status_id: UserSessionStatus.id_for(:blocked), message: 'Browser IP mismatch'}
        session.update(update_attr)
        session.access_token.update(update_attr)
        RequestStoreUtil.current_session_event.update(update_attr)
        response_code 401
        fail
      end
    end
  end

end