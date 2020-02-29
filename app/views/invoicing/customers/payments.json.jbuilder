json.array!(@result.payments_received) do |payment|
  # this will include the details of each payment as well as the invoices that
  # this particular payment has fulfilled
  virtual_account_transaction = payment.virtual_account_transaction
  # first details of the remitter account from which this transaction came through
  json.remitter_account_number virtual_account_transaction.remitter_account_no
  json.remitter_account_ifsc virtual_account_transaction.remitter_account_ifsc
  json.note virtual_account_transaction.note


  # details of the virtual account through which this was paid and the payment details
  json.virtual_account_number payment.initiating_account.account_number
  json.date payment.date
  json.amount payment.amount_value

  # details of the invoices that this payment fulfilled
  json.invoices do
    json.array!(virtual_account_transaction.invoices) do |invoice|
      json.invoice_number invoice.invoice_number
      json.invoice_amount invoice.total_payable&.value
    end
  end
end