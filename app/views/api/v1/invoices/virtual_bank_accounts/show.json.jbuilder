json.extract! @result.virtual_bank_account, :account_number, :ifsc, :description, :name,
              :imps, :neft, :rtgs, :upi, :current_account, :savings_account, :active_after, :active_on, :expires_by
json.maximum_amount @result.virtual_bank_account.maximum_amount_value
json.maximum_transaction_amount @result.virtual_bank_account.maximum_transaction_amount_value
json.minimum_transaction_amount @result.virtual_bank_account.minimum_transaction_amount_value
json.exact_transaction_amount @result.virtual_bank_account.exact_transaction_amount_value
# adding the number of transactions and total amount collected
json.total_transaction_count @result.total_transaction_count
json.total_transaction_amount @result.total_transaction_amount