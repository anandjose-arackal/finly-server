json.success true
json.data do
  json.partial! 'expense', expense: @expense
end