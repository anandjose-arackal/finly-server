json.success true
json.data do
  json.array! @result.receipts do |receipt|
    json.extract! receipt, :id, :user_id, :note, :created_at
    json.image_url do
      json.file_format receipt.file_format
      json.original receipt.image.url
      json.large receipt.image(:large)
      json.normal receipt.image(:normal)
      json.thumb receipt.image(:thumb)
    end
  end
end