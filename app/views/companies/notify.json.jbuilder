json.company_balance @company_balance
if Rails.env.production?
  json.url "https://www.itzcash.com/finly/servlet/AccountReloadServlet"
else
  json.url "https://staging.itzcash.com/loconav/servlet/AccountReloadServlet"
end
# json.encrypted_params @company.configuration.encrypted_easy_login_params
json.encrypted_params @company&.configuration.encrypted_easy_login_params
json.id @company&.id