json.bank_payment_request do
  id = @result&.payment_request&.id rescue nil
  json.id id
end