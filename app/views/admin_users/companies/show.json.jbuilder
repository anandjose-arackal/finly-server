json.id @result.company.id
json.name @result.company.name
json.d_code @result.company.d_code
json.logo @result.company.configuration.logo.url(:thumb)
json.ocr_enabled @result.company.ocr_enabled?
json.balance @result.company_balance