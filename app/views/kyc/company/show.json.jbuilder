kyc = @result.company_kyc
json.status do
  json.id kyc.kyc_status.id
  json.name kyc.kyc_status.name.humanize
end
json.coi kyc.coi.present? ? kyc.coi(:original) : nil
json.pan_card kyc.pan_card.present? ? kyc.pan_card(:original) : nil