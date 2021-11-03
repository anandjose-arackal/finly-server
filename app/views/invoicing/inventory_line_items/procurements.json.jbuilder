# any key added in root should be available in all documents, else
# add it in additional information for that document
# 
json.documents do
  json.array! @result.paginated_documents do |document|
    json.extract! document, :id

    case document.class.name
    when 'Invoice'
      json.document_number document.invoice_number
      json.date document.date
      json.created_by document.created_by&.name
      json.created_at document.created_at&.strftime("%d-%b-%Y")
      json.amount document.net_amount&.value
      json.additional_information do # use this for adding more info specific to this document
        json.procurement_id document.procurement_id
        json.due_date document.due_date
      end
      json.base_currency document.get_base_currency
      json.forms_enabled document.forms_enabled
    when 'PurchaseOrder'
      json.document_number document.po_number
      json.date document.delivery_date
      json.created_by document.user&.name
      json.created_at document.created_at&.strftime("%d-%b-%Y")
      json.amount document.balance_amount&.value
      json.additional_information do
        json.procurement_id document.procurement_id
      end
      json.base_currency document.get_base_currency
      json.forms_enabled document.forms_enabled
    when 'PurchaseRequest'
      json.document_number document.order_number
      json.date document.updated_at.strftime("%d-%b-%Y")
      json.created_by document.creator&.name
      json.created_at document.created_at&.strftime("%d-%b-%Y")
      json.amount document.total_amount&.value
      json.additional_information({})
      json.base_currency document.get_base_currency
      json.forms_enabled document.forms_enabled
    end

  end
end

json.non_po_invoice_form_enabled (@result.current_user.non_po_invoice_form_enabled || @result.current_user.po_invoice_form_enabled)
json.count @result.documents.count