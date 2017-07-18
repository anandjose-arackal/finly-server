json.success true
json.data do
  json.access_token @token.token
  json.token_type 'bearer'
  json.refresh_token @token.refresh_token
  json.expires_in @token.expires_in
  json.user do
    json.extract! @user, :id, :name, :email, :mobile_number
    json.roles @user.admin_user_roles, :id, :name
  end
end