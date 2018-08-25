json.extract! @result.inward_document, :id, :doc_number
json.items do
  json.array! @result.items, :id, :product_id, :description, :quantity, :delivered, :accepted, :rejected
end