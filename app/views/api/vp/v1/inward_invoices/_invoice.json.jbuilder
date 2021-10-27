json.partial! 'invoice_header', record: record
json.line_items do
  json.array! record.items do |item|
    json.id item.id
    json.item_type item.inventory_line_item&.supply_item_type&.name
    json.item_expense_type item.inventory_line_item&.item_expense_type&.name
    json.product_type item.inventory_line_item&.product_type&.name
    json.item_code item.inventory_line_item&.item_number
    json.description item.description
    json.comment item.comment
    json.category item.category
    json.department item.department
    json.cost_center item.cost_center
    json.hsn_sac item.hsn_sac
    json.tds_applicable item.tds_applicable
    json.unit_of_measurement item.unit_of_measurement
    json.quantity item.quantity
    json.rate item.rate
    json.gross_amount item.amount&.value
    json.discount item.discount
    json.discount_amount item.discount_amount&.value
    json.taxable_amount item.taxable_amount&.value
    json.tax_rate item.tax_rate
    json.tax_amount item.tax_amount&.value
    json.net_amount item.net_amount&.value
  end
end

json.comments do
  json.array! record.comments do |comment|
    json.user comment.user&.as_json
    json.user_name comment.user&.name
    json.body comment.body
    json.commented_at comment.created_at
  end
end