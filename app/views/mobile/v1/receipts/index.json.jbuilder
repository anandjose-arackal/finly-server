json.success true
json.data do
  json.array! @result.receipts do |receipt|
    json.extract! receipt, :id, :user_id, :note, :created_at
    json.file_format receipt.file_format
    json.image do
      json.large receipt.image.url
      json.normal receipt.image(:normal)
      json.thumb receipt.image(:thumb)
    end
  end
end