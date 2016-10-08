json.array!(@result.receipts) do |receipt|
  json.extract! receipt, :id, :user_id, :note
  json.url receipt.image.url
  json.image_updated_at receipt.image_updated_at.strftime("%b %d, %Y")
end