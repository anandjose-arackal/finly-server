json.data do
  json.token @op[:token]
  json.expires_in @op[:expires_in]
  json.base_url @op[:base_url]
  json.config @op[:config]
  json.toggles @op[:toggles]
end