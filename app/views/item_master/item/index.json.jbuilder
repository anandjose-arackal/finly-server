# invoice_items = [
#     HashWithIndifferentAccess.new({rate: 10, tax: 5, category_name: 'Junk Category', id: 1, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
#     HashWithIndifferentAccess.new({rate: 11, tax: 10, category_name: 'Junk Category', id: 2, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
#     HashWithIndifferentAccess.new({rate: 12, tax: 12, category_name: 'Junk Category', id: 3, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
#     HashWithIndifferentAccess.new({rate: 14, tax: 18, category_name: 'Junk Category', id: 4, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
#     HashWithIndifferentAccess.new({rate: 11, tax: 5, category_name: 'Junk Category', id: 5, description: 'Junk Item 1', total_amount: 106.857, hsn_sac: "JNK"}),
# ]
#
# json.array!(invoice_items) do |item|
#   json.rate item[:rate]
#   json.tax item[:tax]
#   json.hsn_sac item[:hsn_sac]
#   json.category_name item[:category_name]
#   json.category_id 21
#   json.description item[:description]
# end
json.results do
  json.array!(@result.paginated_line_items) do |item|
    json.merge! item.as_json
  end
end

json.count @result.inventory_line_items.count