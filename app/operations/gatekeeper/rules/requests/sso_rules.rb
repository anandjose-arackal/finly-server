Gatekeeper::Checker.new 'On New Request' do

  before do
    skip unless RequestStoreUtil.current_session&.web?
    skip if RequestStoreUtil.current_session.admin_user_id.present?
    skip unless RequestStoreUtil.current_session.access_token.authentication_type == "sso"
  end

  premise :on_authenticated_request do

  end

end