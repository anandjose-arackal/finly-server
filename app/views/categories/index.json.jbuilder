json.categories do
  json.array!(@result.categories.roots) do |category|
    json.id category.id
    json.name category.name
    json.gl_code category.gl_code
    json.gst_enabled category.gst_applicable
    json.tds_enabled category.tds_applicable
    if category.children.present?
      json.sub_categories do
        json.array!(category.children) do |sub_category|
          json.id sub_category.id
          json.name sub_category.name
          json.gst_enabled category.gst_applicable
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


json.em_categories do
  json.array!(@result.em_categories&.roots) do |category|
    json.id category.id
    json.name category.name
    json.gl_code category.gl_code
    json.gst_enabled category.gst_applicable
    json.tds_enabled category.tds_applicable
    if category.children.present?
      json.sub_categories do
        json.array!(category.children) do |sub_category|
          json.id sub_category.id
          json.name sub_category.name
          json.gst_enabled category.gst_applicable
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

json.vp_categories do
  json.array!(@result.vp_categories&.roots) do |category|
    json.id category.id
    json.name category.name
    json.gl_code category.gl_code
    json.gst_enabled category.gst_applicable
    json.tds_enabled category.tds_applicable
    if category.children.present?
      json.sub_categories do
        json.array!(category.children) do |sub_category|
          json.id sub_category.id
          json.name sub_category.name
          json.gst_enabled category.gst_applicable
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

json.categories_count @result.categories.roots.count
json.vp_categories_count @result.vp_categories.roots.count
json.em_categories_count @result.em_categories.roots.count

json.show_sync_button (current_company.quickbooks_configuration.present?)