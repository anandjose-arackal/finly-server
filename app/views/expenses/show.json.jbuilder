json.extract! @expense, :id, :note, :merchant_name, :user_id, :user_name, :amount_value, :category_name

# json.receipts @expense.receipts, :id, :image_file_name


json.receipts @expense.receipts do |receipt|
  json.id receipt.id
  # json.image_file_name asset_path(receipt.image_file_name)
  # json.image_url url_for(receipt.image_file_name)
  json.image_url receipt.image.url
end