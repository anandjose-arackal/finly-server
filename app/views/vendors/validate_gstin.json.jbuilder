if @result.valid_response
  json.response @result.response_body
  json.match_percentile @result.match_percentile
else
  json.response @result.response_body
end