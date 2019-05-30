# json.locations do
#   json.array!(@result.locations) do |location|
#     json.merge! location.as_json
#   end
# end
# json.array! @result.locations&.map(&:json_tree)
# json.array! @result.locations.roots&.map(&:json_tree)
json.locations @result.locations.roots&.map(&:json_tree)

# used in vp organization account
json.all_locations @result.all_locations&.map(&:json_tree)