json.id @result.company.id
json.name @result.company.name
json.d_code @result.company.d_code
json.logo @result.company.configuration.logo.url(:thumb)
json.ocr_enabled @result.company.ocr_enabled?
json.expense_management_enabled @result.company.expense_management_enabled?
json.gift_card_enabled @result.company.gift_card_enabled?
json.gift_voucher_enabled @result.company.gift_voucher_enabled?
json.meal_card_enabled @result.company.meal_card_enabled?
json.fuel_card_enabled @result.company.fuel_card_enabled?
json.medical_card_enabled @result.company.medical_card_enabled?
json.expense_card_enabled @result.company.expense_card_enabled?
json.reimbursement_card_enabled @result.company.reimbursement_card_enabled?
json.balance @result.company_balance
json.hard_copy_receipt @result.company.hard_copy_receipt_enabled?
json.encrypted_params @result.company.configuration.encrypted_easy_login_params

if Rails.env.production?
  json.url "https://www.itzcash.com/finly/servlet/AccountReloadServlet"
else
  json.url "https://staging.itzcash.com/loconav/servlet/AccountReloadServlet"
end

json.kyc do
  kyc = @result.company.company_kyc
  editable = (kyc.editable? or [KycStatus.id_for(:processing)].include?(kyc.kyc_status_id))
  json.editable editable
  json.status do
    json.id kyc.kyc_status.id
    json.name kyc.kyc_status.name.humanize
  end
  json.coi do
    json.file_type kyc.file_format(kyc.coi)
    json.original kyc&.coi&.url
    json.thumb kyc&.coi&.url(:thumb)
  end
  json.pan_card do
    json.file_type kyc.file_format(kyc.pan_card)
    json.original kyc&.pan_card&.url
    json.thumb kyc&.pan_card&.url(:thumb)
  end
  json.system_messages do
    json.array!(kyc&.system_messages.pluck(:content))
  end
end