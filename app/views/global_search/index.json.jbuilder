# json.data do
#   json.hits @op[:response]&.dig('hits')
#   json.facets_distribution @op[:response]&.dig('facetsDistribution')
# end