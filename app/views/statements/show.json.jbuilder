json.account_name @result.account_name
json.opening_balance @result.opening_balance
json.closing_balance @result.closing_balance
json.credits_count @result.credits_count
json.debits_count @result.debits_count
json.credit_amount @result.credit_amount
json.debit_amount @result.debit_amount
json.finly_transactions do
  json.array! @result.account_transactions do |finly_transaction|
    json.reference_id finly_transaction.transaction_reference_id
    json.date DateUtils.date_formatted finly_transaction.date
    json.transaction_type finly_transaction.transaction_type.name.humanize
    json.purpose finly_transaction.payment_purpose.name.humanize
    json.merchant @result.merchant(finly_transaction)
    credit_amount = nil
    debit_amount = nil
    if finly_transaction.credit?
      credit_amount = finly_transaction.amount.value.to_s
    else
      debit_amount = finly_transaction.amount.value.to_s
    end
    json.credit_amount credit_amount
    json.debit_amount debit_amount
    json.closing_balance finly_transaction.closing_balance&.value&.to_s
    json.status finly_transaction.status.name.humanize
    json.system_messages do
      json.system_messages do
        json.array! finly_transaction.system_messages
      end
    end
  end
end