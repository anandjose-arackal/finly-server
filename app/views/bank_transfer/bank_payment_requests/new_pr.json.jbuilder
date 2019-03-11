# json.bank_payment_request do
#   id = @result&.bank_payment_request&.id rescue nil
#   json.id id
# end

json.bank_payment_request_id @result.bank_payment_request_id