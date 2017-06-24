if @auth_grant and @auth_grant&.user.company_admin?
  json.access_token @auth_grant.access_token
  json.token_type Opro.token_type || 'bearer'
  json.refresh_token @auth_grant.refresh_token
  json.expires_in @auth_grant.expires_in
  json.user @auth_grant.user, :id, :name, :email, :mobile_number
  json.company do
    json.id @auth_grant.user.company.id
    json.name @auth_grant.user.company.name
    json.logo do
      logo = @auth_grant.user.company.configuration.logo
      json.original logo.present? ? logo(:original) : nil
      json.thumb logo.present? ? logo(:thumb) : nil
    end
  end
else
  json.error 'Could not find a user that belongs to this application using username and password'
end