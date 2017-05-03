
json.array!(@result.receipts) do |receipt|
  json.extract! receipt, :id, :user_id, :note
  # json.url receipt.image.url
  json.image_updated_at receipt.image_updated_at.strftime("%b %d, %Y")
  # json.file_type receipt.file_format
  json.categories do
    json.array!(@result.categories) do |category|
      json.id category.id
      json.name category.name
    end
  end
  json.image do
    json.file_type receipt.file_format
    json.original receipt.image.url
    json.thumb receipt.image.url(:thumb)
  end
  json.system_messages do
    json.array!(receipt.system_messages.pluck(:content))
  end

  json.ocr_enabled receipt.user.company.ocr_enabled?
end
