class AuthenticationToggle < ApplicationToggle

  def sso_google_enabled?
    feature_flag 'permissions/auth/sso/google#enabled', true
  end

  def sso_okta_enabled?
    feature_flag 'permissions/auth/sso/okta#enabled', true
  end
  
  def sso_2fa_enabled?
    feature_flag 'permissions/auth/sso/2fa/adaptive#enabled', true
  end

  def password_enabled?
    feature_flag 'permissions/auth/password#enabled', true
  end
end

    