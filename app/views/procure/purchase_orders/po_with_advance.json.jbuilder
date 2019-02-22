json.array!(@result.paginated_purchase_order) do |purchase_order|
  # json.account_details do
  #   json.account_number purchase_order.receiving_account.account_number
  #   json.ifsc purchase_order.receiving_account.ifsc
  # end
  json.po_due_date purchase_order.due_date.strftime("%d-%m-%Y")
  json.po_created_at purchase_order.created_at.strftime("%d-%m-%Y")
  # json.po_advance_amount_value purchase_order.advance_amount.value
  # json.po_advance_amount_currency purchase_order.advance_amount.currency.country_code
  json.po_advance_amount purchase_order.advance_amount
  json.po_total_after_tax purchase_order.total_after_tax
  json.po_id purchase_order.id
  json.po_payment_status purchase_order.status&.name&.humanize
  json.po_number purchase_order.po_number
  json.po_vendor_name purchase_order.vendor.name
end