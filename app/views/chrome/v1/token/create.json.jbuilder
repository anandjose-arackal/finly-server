json.access_token @token.token
json.token_type 'bearer'
json.refresh_token @token.refresh_token
json.expires_in @token.expires_in
json.user @user, :id, :name, :email, :mobile_number
json.company do
  json.id @user.company.id
  json.name @user.company.name
  json.logo do
    configuration = @user.company.configuration
    json.original configuration.logo.present? ? configuration.logo(:original) : nil
    json.thumb configuration.logo.present? ? configuration.logo(:thumb) : nil
  end
end