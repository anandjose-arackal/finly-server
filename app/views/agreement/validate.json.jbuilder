if @result.success?
  json.agreed @result.agreed
  json.kyc_required @result.kyc_required
end