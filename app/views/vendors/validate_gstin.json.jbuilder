if @result.valid_response
  json.result do
    json.extract! @result.gstin_master, :id, :gstin, :legal_name_of_business, :state, :date_of_registration,
                  :constitution_of_business, :taxpayer_type, :status, :api_response

  end
  json.match_percentile @result.match_percentile
else
  json.response @result.response_body
end