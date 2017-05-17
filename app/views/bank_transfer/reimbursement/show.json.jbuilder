json.enabled @result.enabled
json.mobile_number @result.mobile_number
json.reimbursement_accounts do
  if @result.reimbursement_accounts.blank?
    nil
  else
    json.array! @result.reimbursement_accounts.each do |account|
      json.id account.id
      json.bank_name account.beneficiary_name
      json.account_number account.viewable_account_number
      json.default account.default
    end
  end
end

