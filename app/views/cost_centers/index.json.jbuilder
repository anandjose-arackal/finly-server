# json.array!(@result.cost_centers) do |cost_center|
#   json.name cost_center.name
#   json.id cost_center.id
# end

# json.array! @result.cost_centers.roots&.map(&:json_tree)
json.cost_centers @result.cost_centers.roots&.map(&:json_tree)

# used in vp organization account
json.all_cost_centers @result.all_cost_centers&.map(&:json_tree)