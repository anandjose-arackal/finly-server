json.expense do
  json.partial! 'expense', expense: @result.expense
end
json.duplicate_expenses do
  json.array! @result.duplicate_expenses.each do |expense|
    json.partial! 'expense', expense: expense
    json.deletable expense.can_delete?
    json.receipts @result.expense.receipts do |receipt|
      json.id receipt.id
      json.image do
        json.file_type receipt.file_format
        json.original receipt.image.url
        json.thumb receipt.image.url(:thumb)
      end
    end
  end
end