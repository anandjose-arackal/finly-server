# json.array!(@result.charts) do |chart|
#   chart.each do |key, value|
#     json.category key
#     json.total precision_value value
#   end
# end
json.array!(@result.charts)