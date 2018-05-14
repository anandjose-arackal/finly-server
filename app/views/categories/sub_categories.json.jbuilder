json.categories do
  json.array!(@result.categories) do |category|
    json.id category.id
    json.name category.name
    json.expense_management category.expense_management
    json.vendor_payments category.vendor_payments
    json.inward_invoice_line_items category.inward_invoice_line_items
    json.outward_invoices category.outward_invoices
    json.outward_invoice_line_items category.outward_invoice_line_items
  end
end