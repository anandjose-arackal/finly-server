json.id @result.user_team.id
json.name @result.user_team.name
json.selected_group_items @result.selected_group_items
json.groups do
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
end
json.users do
  json.array! @result.users do |user|
    json.id user.id
    json.name user.name
    json.email user.email
    json.mobile_number user.mobile_number
  end
end
