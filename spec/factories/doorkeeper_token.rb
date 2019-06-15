FactoryBot.define do
  factory :doorkeeper_token, class: Doorkeeper::AccessToken do
    application_id {1}
    token {SecureRandom.hex(32)}
    refresh_token {SecureRandom.hex(32)}
    expires_in {3900000}
    revoked_at {nil}
    created_at {DateTime.now}
    scopes {'web'}
    status_id {UserSessionStatus.id_for(:authorized)}
  end
end