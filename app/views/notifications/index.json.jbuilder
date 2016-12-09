json.array!(@notifications) do |notif|
  json.extract! notif, :read
  json.body notif.generate_body(current_user)
  json.title notif.generate_title
  json.date notif.timestamp.strftime("%y %b %d")
  json.time notif.timestamp.strftime("%l:%M %p")
end