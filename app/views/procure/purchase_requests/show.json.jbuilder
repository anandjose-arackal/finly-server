# this is a sample for the frontend
json.result do
  json.purchase_request do
    json.id rand(500)
    json.title "Sample Title"
    json.department "Sample Dept"
    json.location "Valhalla - #{rand(10)}"
    json.created_by do
      json.name "What's in a name"
      json.created_at Date.today-rand(10000)
    end
    json.status ["Delivered", "Pending", "Rejected", "Draft", "Awaiting Approval"][rand(5).to_i]
    json.policy do 
      json.name ["Company (Default)", "Finly Policy", "PR Policy"][rand(3)]
      json.id rand(3) + 1
    end
    json.total_cost "5000000"
    json.total_items rand(10..100)
    json.line_items do
      json.array!((1..10).to_a) do |i|
        json.id rand(10) * i
        json.product_name "didlo"
        json.vendor_name "amazon india pvt ltd"
        json.vendor_id i
        json.delivery_date "13-03-2019"
        json.delivery_location "Thiruvananthapuram"
        json.purpose "lorem lorem lorem lorem lorem lorem lroemloremlorem lorem lorem"
        json.quantity rand(10..20) * i
        json.unit_type "each"
        json.estimated_cost do
          json.currency_id 1
          json.value 70002.0
          json.id  8838784
        end
        json.unit_cost do
          json.currency_id 1
          json.value 599
          json.id  8784
        end
      end
    end
  end
end