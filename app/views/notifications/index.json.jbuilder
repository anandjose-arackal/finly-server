json.array!(@result.notifications) do |notif|
  json.extract! notif, :read
  json.record_type notif.record_type&.downcase&.gsub(" ", "_")
  json.body notif.generate_body(current_user)
  json.title notif.generate_title
  json.date notif.timestamp.strftime("%d %b %Y")
  json.time notif.timestamp.strftime("%l:%M %p")
  json.link notif.generate_link(current_user)
end