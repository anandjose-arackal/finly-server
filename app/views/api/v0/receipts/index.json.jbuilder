json.success true
json.data do
  json.array! @result.receipts do |receipt|
    json.extract! receipt, :id, :user_id, :note, :created_at
    json.image_url do
      json.large receipt.image(:large)
      json.normal receipt.image(:normal)
      json.thumb receipt.image(:thumb)
    end
  end
end