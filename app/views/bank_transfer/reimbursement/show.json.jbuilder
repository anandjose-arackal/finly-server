json.enabled @result.enabled
json.reimbursement_accounts do
  json.array! @result.reimbursement_accounts.each do |account|
    json.id account.id
    json.account_number account.viewable_account_number
    json.name account.beneficiary_name
    json.default account.default
  end
end
