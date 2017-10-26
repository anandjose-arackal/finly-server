json.account_number @result.virtual_bank_account.account_number
json.ifsc @result.virtual_bank_account.ifsc
json.amount @result.payment_receivable.amount&.value
json.expire_by @result.payment_receivable.expire_by&.strftime("%m %B, %Y")