json.name @result.item.name
json.id @result.item.id
json.group do
  json.name @result.group.name
  json.id @result.group.id
end
json.users do
  json.array! @result.users, :id, :name, :mobile_number, :email
end

json.pending_users do
  json.array! @result.addable_users, :id, :name, :mobile_number, :email
end