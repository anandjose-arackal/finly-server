json.success true
json.data do
  json.access_token @auth_grant.access_token
  json.token_type Opro.token_type || 'bearer'
  json.refresh_token @auth_grant.refresh_token
  json.expires_in @auth_grant.expires_in
  json.user do
    json.extract! @auth_grant.user, :id, :name, :email
    json.roles @auth_grant.user.user_roles, :id, :name
  end
  json.company do
    json.id @auth_grant.user.company.id
    json.name @auth_grant.user.company.name
  end
end