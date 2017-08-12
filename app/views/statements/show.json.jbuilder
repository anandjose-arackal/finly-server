json.opening_balance @result.opening_balance
json.closing_balance @result.closing_balance
json.credits_count @result.credits_count
json.debits_count @result.debits_count
json.credit_amount @result.credit_amount
json.debit_amount @result.debit_amount
json.transactions_tab @result.has_transactions_tab?
json.finly_transactions do
  json.array! @result.scoped_finly_transactions do |finly_transaction|
    # todo - remove id. just for testing
    # json.id finly_transaction.id
    json.date DateUtils.date_formatted finly_transaction.created_at
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
    json.system_messages do
      json.system_messages do
        json.array! finly_transaction.system_messages
      end
    end
  end
end
if @result.has_transactions_tab?
  json.card_transactions do
    json.array! @result.scoped_card_transactions do |card_transaction|
      json.date '12 August 2017'
      json.transaction_type 'Debit'
      json.purpose 'Payment'
      json.merchant 'Test Merchant'
      json.credit_amount 2
      json.debit_amount 1
      json.closing_balance 500
      json.status 'Verified'
    end
  end
end