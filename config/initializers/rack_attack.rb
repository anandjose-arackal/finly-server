Rack::Attack.blocklist_ip('192.168.1.215')

ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|
  # request object available in payload[:request]
  binding.pry
  # Your code here
end