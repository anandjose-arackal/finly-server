json.array!(@result.invoices_paid) do |invoice|
  # this will contain details about the invoice
  json.extract! invoice, :id, :invoice_number, :date, :due_date, :status_name
  json.paid_amount invoice.paid_amount&.value

  # now including data about the various transactions that were used to pay this invoice
  transactions = invoice.va_transactions
  json.transactions do
    json.array!(transactions) do |virtual_account_transaction|
      json.remitter_account_number virtual_account_transaction.remitter_account_no
      json.remitter_account_ifsc virtual_account_transaction.remitter_account_ifsc
      json.note virtual_account_transaction.note
      payment = virtual_account_transaction.payment
      # details of the virtual account through which this was paid and the payment details
      json.virtual_account_number payment.initiating_account.account_number
      json.date payment.date
      json.amount payment.amount_value
    end
  end
end