json.invoice_categories do
  json.array!(current_company.categories.vendor_payments_only) do |category|
    json.extract! category, :name, :id
  end
end

json.invoice_items_categories do
  json.array!(current_company.categories.inward_invoice_line_items_only) do |category|
    json.extract! category, :name, :id
  end
end

json.tds_slabs do
  json.array!(current_company.tds_slabs) do |tds_slab|
    json.extract! tds_slab, :name, :id, :tds
  end
end

json.cost_centers do
  json.array!(current_company.cost_centers.non_deleted) do |cost_center|
    json.extract! cost_center, :id, :name
  end
end

json.custom_field_configurations current_company.field_configurations.with_parent_type(FieldParentType.id_for(:invoice))