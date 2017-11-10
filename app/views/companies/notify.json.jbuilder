json.company_balance @company_balance
if Rails.env.production?
  json.url "https://www.itzcash.com/finly/servlet/AccountReloadServlet"
else
  json.url "https://staging.itzcash.com/loconav/servlet/AccountReloadServlet"
end
# json.encrypted_params @company.configuration.encrypted_easy_login_params
json.encrypted_params @company&.configuration.encrypted_easy_login_params
json.id @company&.id

json.payu_enabled @company&.configuration.encrypted_easy_login_params.present?

# adding HDFC versus RBL details for transferring money into Company Credits (Card Transfer Credits)
if @company.hdfc?
  json.account_number "00600330004211"
  json.ifsc "HDFC0000060"
  json.bank_name "HDFC BANK"
  json.branch_name "Fort"
  json.address "Fort-400001"
elsif @company.rbl?
  json.account_number "409000601253"
  json.ifsc "RATN0000070"
  json.bank_name "RBL Bank Limited"
  json.branch_name "Fort"
  json.address "Fort-400001"
end
