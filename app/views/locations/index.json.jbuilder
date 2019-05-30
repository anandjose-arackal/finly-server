# json.locations do
#   json.array!(@result.locations) do |location|
#     json.merge! location.as_json
#   end
# end
json.array! @result.locations&.map(&:json_tree)