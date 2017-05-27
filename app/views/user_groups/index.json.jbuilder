json.array! @result.user_groups do |group|
  json.id group.id
  json.name group.name
  json.items do
    json.array! group.user_group_items do |item|
      json.id item.id
      json.name item.name
    end
  end
end