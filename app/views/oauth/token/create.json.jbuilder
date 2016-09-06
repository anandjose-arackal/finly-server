json.access_token @auth_grant.access_token
json.token_type Opro.token_type || 'bearer'
json.refresh_token @auth_grant.refresh_token
json.expires_in @auth_grant.expires_in
json.extract! @auth_grant.user, :id, :name, :email
json.user_roles @auth_grant.user.user_roles, :id, :name
json.company_id @auth_grant.user.company.id
json.company_name @auth_grant.user.company.name