json.array!(@result.receipts) do |receipt|
  json.extract! receipt, :id, :user_id, :note
  # json.url receipt.image.url
  json.image_updated_at receipt.image_updated_at.strftime("%b %d, %Y")
  categories = receipt.user.company.categories.active
  json.categories do
    json.array!(categories) do |category|
      json.id category.id
      json.name category.name
    end
  end
  # json.file_type receipt.file_format
  json.image do
    json.file_type receipt.file_format
    json.original receipt.image.url
    json.thumb receipt.image.url(:thumb)
  end
  json.parent_id receipt.parent_id
end