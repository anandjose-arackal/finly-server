json.account_name @result.account_name
json.opening_balance AmountUtils.format(@result.opening_balance, placeholder: '-')
json.closing_balance AmountUtils.format(@result.closing_balance, placeholder: '-')
json.credits_count AmountUtils.format(@result.credits_count, placeholder: '-')
json.debits_count AmountUtils.format(@result.debits_count, placeholder: '-')
json.credit_amount AmountUtils.format(@result.credit_amount, placeholder: '-')
json.debit_amount AmountUtils.format(@result.debit_amount, placeholder: '-')
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
      credit_amount = finly_transaction.amount.value
    else
      debit_amount = finly_transaction.amount.value
    end
    json.credit_amount AmountUtils.format(credit_amount, placeholder: '-')
    json.debit_amount AmountUtils.format(debit_amount, placeholder: '-')
    json.closing_balance AmountUtils.format(finly_transaction.closing_balance&.value, placeholder: '-')
    json.status finly_transaction.status.name.humanize
    json.system_messages do
      json.system_messages do
        json.array! finly_transaction.system_messages
      end
    end
  end
end