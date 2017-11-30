json.extract! @result.virtual_bank_account, :account_number, :ifsc, :description, :name, :expires_by,
              :imps, :neft, :rtgs, :upi, :current_account, :savings_account, :date_after, :date_on
json.maximum_amount @result.virtual_bank_account.maximum_amount_value
json.maximum_transaction_amount @result.virtual_bank_account.maximum_transaction_amount_value
json.minimum_transaction_amount @result.virtual_bank_account.minimum_transaction_amount_value
json.exact_transaction_amount @result.virtual_bank_account.exact_transaction_amount_value