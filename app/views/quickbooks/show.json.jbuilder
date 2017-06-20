json.payment_order_date @result.qb_config.transaction_date_field
json.reimbursement_account_id @result.qb_config.reimbursable_account_id
json.non_reimbursement_account_id @result.qb_config.non_reimbursable_account_id

json.payment_accounts do
  json.array!(@result.company.quickbooks_payment_types) do |qbp|
    json.name qbp.name
    json.id qbp.id
  end
end