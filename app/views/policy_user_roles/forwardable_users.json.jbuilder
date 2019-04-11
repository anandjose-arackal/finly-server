# json.documents do
#   json.array! @result.documents do |document|

#   end
# end

json.summary do
  json.count @result.documents.count
  json.document_ids @result.documents.pluck(:id)
end

json.users do
  json.array! @result.paginated_policy_user_roles do |pur|
    json.merge! pur.user.as_json
  end
end