json.account_number @result.virtual_bank_account.account_number
json.expires_by @result.virtual_bank_account.expires_by&.strftime("%d %B, %Y")
json.ifsc @result.virtual_bank_account.ifsc
json.description @result.virtual_bank_account.description
json.initiating_user @result.virtual_bank_account.initiating_user&.name