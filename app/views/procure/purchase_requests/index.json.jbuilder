# this is a sample for the frontend
json.array!((1..10).to_a) do |i|
  json.id i
  json.title "Sample Title"
  json.department "Sample Dept"
  json.location "Valhalla - #{i}"
  json.total_items i*3
  json.created_by do
    json.name "What's in a name"
    json.created_at Date.today-rand(10000)
  end
  json.status ["Delivered", "Pending", "Rejected", "Draft", "Awaiting Approval"][rand(5).to_i]
end