json.opening_balance @result.opening_balance
json.closing_balance @result.closing_balance
json.credits_count @result.credits_count
json.debits_count @result.debits_count
json.transactions_tab @result.has_transactions_tab?
json.payments do
  json.array! @result.payments do |payment|
    json.date DateUtils.date_formatted payment.date
    json.payment_type @result.payment_type(payment)
    json.purpose @result.purpose(payment)
    json.merchant @result.merchant(payment)
    json.credit @result.credit(payment)
    json.debit @result.debit(payment)
    json.initiating_user do

    end
    json.receiving_user do

    end
    json.note
    json.initiating_account do

    end
    json.receiving_account do

    end
    json.status do

    end
    json.purpose
    json.closing_balance
  end
end
if @result.has_transactions_tab?
  json.transactions do
    json.array! @result.card_transactions do |card_transaction|

    end
  end
end