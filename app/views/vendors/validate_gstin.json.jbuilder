if @result.valid_response
  json.result do
    json.valid_response true
    json.extract! @result.gstin_master, :id, :gstin, :legal_name_of_business, :state, :date_of_registration,
                  :constitution_of_business, :taxpayer_type, :status, :address

    json.response @result.gstin_master.api_response
    json.match_percentile @result.match_percentile
    json.trade_name_match_percentile @result.trade_name_match_percentile
  end
else
  json.result do
    json.valid_response false
    if @result.response_body[:data].instance_of?(String)
      json.messages do
        json.array! [@result.response_body[:data]]
      end
    end
  end
end