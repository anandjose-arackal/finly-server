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
  json.expense_id receipt.parent_id

  if receipt.parent.present?
    expense = receipt.parent
    json.expense do
      json.amount expense.amount_value
      json.merchant expense.merchant_name
      json.date expense.date.strftime("%b %d, %Y")
      json.note expense.note
      json.category_id expense.category_id
      json.category_name expense.category_name
      json.system_messages do
        json.array!(expense.system_messages.pluck(:content))
      end
    end
  end
end