json.trail do
  json.array!(@result.trails) do |trail|
    json.statement trail.generate_in_words
    json.timestamp trail.created_at.strftime("%Y-%B-%D, at %H-%M-%S")
  end
end