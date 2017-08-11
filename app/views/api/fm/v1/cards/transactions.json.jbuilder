json.transactions do
  json.array! @result.transactions.each do |transaction|
    json.extract! transaction, :id, :transaction_type, :merchant_name,
                  :reference_id, :auth_transaction_id,  :transaction_mode, :response_code,
                  :transaction_timestamp, :mcc_code, :transaction_status, :api_reference_id,
                  :cancelled, :type_of_details
    json.user do
      json.id transaction.user.id
      json.name transaction.user.name
      json.email transaction.user.email
      json.mobile_number transaction.user.mobile_number
    end
    json.card do
      json.id transaction.card_id
      json.serial_id transaction.serial_id
    end
    json.transaction_amount do
      json.partial! 'shared/amount', amount: transaction.transaction_amount
    end
    json.billing_amount do
      json.partial! 'shared/amount', amount: transaction.billing_amount
    end
    json.merchant_key transaction.itzcash_merchant_key
    json.merchant_city transaction.merchant_city
  end
end