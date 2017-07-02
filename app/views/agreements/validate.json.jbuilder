if @result.success?
  json.agreed @result.agreed
  json.kyc_required @result.kyc_required
  json.point_of_contact @result.point_of_contact
end