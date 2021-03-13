GOOGLE_OAUTH = {
  'issuer': "Finly",
  'redirect_uri': "/auth/sso/google_oauth/callback",
  'label': "Sign in With Google",
  'client_id': Rails.application.credentials[:omniauth][:google][:client_id],
  'client_secret': Rails.application.credentials[:omniauth][:google][:secret_id],
  'type': "oauth2"
}
