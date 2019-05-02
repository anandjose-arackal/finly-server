json.array! @result.trails.reverse_each do |trail|
  json.merge! trail.as_json
end
