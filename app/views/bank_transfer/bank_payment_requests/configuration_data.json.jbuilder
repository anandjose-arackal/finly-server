json.departments do
  json.array!(@result.departments.departments.roots) do |department|
    json.id department.id
    json.name department.name
    if department.children.present?
      json.sub_departments do
        json.array!(department.children) do |sub_department|
          json.id sub_department.id
          json.name sub_department.name
        end
      end
    end
  end
end

json.categories do
  json.array!(@result.categories.categories.roots) do |category|
    json.id category.id
    json.name category.name
    json.gl_code category.gl_code
    if category.children.present?
      json.sub_categories do
        json.array!(category.children) do |sub_category|
          json.id sub_category.id
          json.name sub_category.name
          json.gl_code sub_category.gl_code
          json.expense_management sub_category.expense_management
          json.vendor_payments sub_category.vendor_payments
          json.inward_invoice_line_items sub_category.inward_invoice_line_items
          json.outward_invoices sub_category.outward_invoices
          json.outward_invoice_line_items sub_category.outward_invoice_line_items
        end
      end
    end
    json.expense_management category.expense_management
    json.vendor_payments category.vendor_payments
    json.inward_invoice_line_items category.inward_invoice_line_items
    json.outward_invoices category.outward_invoices
    json.outward_invoice_line_items category.outward_invoice_line_items
  end
end

json.policies do
  json.array!(@result.policies.policies) do |policy|
    json.id policy.id
    json.name policy.name
  end
end

json.cost_centers do
  json.array!(@result.cost_centers.cost_centers) do |cost_center|
    json.name cost_center.name
    json.id cost_center.id
  end
end

json.tds_slabs do
    json.array!(@result.tds_slabs.tds_slabs) do |tds_slab|
      json.id tds_slab.id
      json.name tds_slab.name
      json.tds tds_slab.tds
    end
end

json.invoice_custom_fields_config @result.custom_fields_config[:invoice]
