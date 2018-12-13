json.result do
  json.array!(@result.paginated_payments) do |payment|
    virtual_trans = payment.reference_resource
    json.source_account do
      json.name virtual_trans&.remitter_full_name
      json.ifsc virtual_trans&.remitter_account_ifsc
      json.account_number virtual_trans&.remitter_account_no
    end
    json.amount payment.amount_value
    json.utr virtual_trans&.transfer_id
    json.note payment.reference_resource&.note
    json.date payment.date
    json.virtual_account do
      json.account_number virtual_trans&.virtual_account&.account_number
      json.ifsc virtual_trans&.virtual_account&.ifsc
      json.name virtual_trans&.virtual_account&.name
    end
    json.purpose virtual_trans&.virtual_account&.purpose&.name&.humanize
    if virtual_trans&.virtual_account&.purpose_id == VirtualAccountPurpose.id_for(:invoice)
      json.invoices do
        json.array!(virtual_trans.invoices) do |invoice|
          json.id invoice.id
          json.invoice_number invoice.invoice_number
          json.paid_amount invoice.paid_amount&.value
        end
      end
      json.remaining_amount (virtual_trans.invoices.joins(:balance_due).sum(:value) - payment.amount_value)
      json.expected_amount virtual_trans.invoices.joins(:balance_due).sum(:value)
    end
  end
end

json.count @result.count