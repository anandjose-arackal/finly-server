json.extract! @result.expense, :id, :note, :merchant_name, :user_id, :user_name, :amount_value, :category_name, :category_id

json.date @result.expense.date.strftime("%d %b")
json.formatted_date @result.expense.date.strftime("%Y-%m-%d")
# json.receipts @expense.receipts, :id, :image_file_name


json.receipts @result.expense.receipts do |receipt|
  json.id receipt.id
  # json.image_file_name asset_path(receipt.image_file_name)
  # json.image_url url_for(receipt.image_file_name)
  json.image_url receipt.image.url
end

json.violations @result.violation

json.editable (@result.expense.report_id.blank? or @result.expense.report.editable?)