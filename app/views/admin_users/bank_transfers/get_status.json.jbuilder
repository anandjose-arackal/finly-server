
json.bank_transaction do
  transaction = @result.transaction
  json.unique_request_number transaction&.unique_request_number
  json.bank_reference_number transaction&.bank_reference_number
  json.amount transaction&.amount&.value
  json.status @result.status
end


