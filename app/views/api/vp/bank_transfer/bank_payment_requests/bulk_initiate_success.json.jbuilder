if current_company.request_encryption_enabled?
  json.encrypted_response @result.construct_response
else
  json.bank_payment_request_id @result.bank_payment_request.id
end