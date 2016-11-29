json.array!(@nots) do |noti|
  json.extract! noti, :title, :body, :read
  json.date Time.now.strftime("%y %b %d")
  json.time Time.now.strftime("%l:%M %p")
end