json.company_balance @company_balance
# if Rails.env.production?
json.url "https://www.itzcash.com/finly/servlet/AccountReloadServlet"
# else
#   json.url 'https://staging.itzcash.com/loconav/servlet/AccountReloadServlet'
# end
# json.encrypted_params @company.configuration.encrypted_easy_login_params
json.encrypted_params "9e803be674300eb6d8a00a32ca16163023c8eb73416f0209de881a9562e513f4"
json.id @company.id