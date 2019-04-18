if @result.account.is_a?(UserPocket)
  json.base_currency @result.account.base_currency
  currency = @result.account.base_currency
else
  # because any other account has INR as the base curency
  json.base_currency Currency.first.as_json
  currency = Currency.first
end
json.account_name @result.account_name
json.opening_balance AmountUtils.format(@result.opening_balance, placeholder: '-', currency: currency)
json.closing_balance AmountUtils.format(@result.closing_balance, placeholder: '-', currency: currency)
json.credits_count AmountUtils.format(@result.credit_count_value, placeholder: '-', currency: currency)
json.debits_count AmountUtils.format(@result.debit_count_value, placeholder: '-', currency: currency)
json.credit_amount AmountUtils.format(@result.credit_amount_value, placeholder: '-', currency: currency)
json.debit_amount AmountUtils.format(@result.debit_amount_value, placeholder: '-', currency: currency)
json.summary do
  summary = @result.summary_data
  json.credits do
    json.array! summary[:credits].map{|item| "#{item[:name]}: <b>#{item[:amount]}</b>"}
  end
  json.debits do
    json.array! summary[:debits].map{|item| "#{item[:name]}: <b>#{item[:amount]}</b>"}
  end
end
json.finly_transactions do
  json.array! @result.account_transactions do |finly_transaction|
    transaction_detail = finly_transaction.transaction_detail
    json.reference_id transaction_detail.transaction_reference_id
    json.date DateUtils.date_formatted transaction_detail.transaction_date
    json.transaction_type StringUtils.titleize(transaction_detail.transaction_type)
    json.purpose StringUtils.titleize(transaction_detail.payment_purpose)
    json.merchant transaction_detail.merchant
    credit_amount = nil
    debit_amount = nil
    if finly_transaction.credit?
      credit_amount = transaction_detail.amount.value
    else
      debit_amount = transaction_detail.amount.value
    end
    json.credit_amount AmountUtils.format(credit_amount, placeholder: '-', currency: currency)
    json.debit_amount AmountUtils.format(debit_amount, placeholder: '-', currency: currency)
    json.closing_balance AmountUtils.format(finly_transaction.closing_balance&.value, placeholder: '-', currency: currency)
    json.status StringUtils.titleize(transaction_detail.status)
    json.system_messages do
      json.system_messages do
        json.array! finly_transaction.system_messages
      end
    end
    json.note transaction_detail.get_note
  end
end