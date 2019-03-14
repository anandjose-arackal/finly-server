json.array! @result.trails do |trail|
  json.merge! trail.as_json
end
