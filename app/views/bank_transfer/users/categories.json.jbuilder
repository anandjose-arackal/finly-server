json.invoice_categories do
  json.array!(@result.invoice_categories) do |category|
    json.id category.id
    json.name category.name
  end
end

json.invoice_line_items_categories do
  json.array!(@result.invoice_line_items_categories) do |category|
    json.id category.id
    json.name category.name
  end
end

json.invoice_custom_fields do
  json.array!(@result.invoice_categories) do |category|
    # todo
  end
end

json.invoice_line_items_custom_fields do
  json.array!(@result.invoice_categories) do |category|
    # todo
  end
end