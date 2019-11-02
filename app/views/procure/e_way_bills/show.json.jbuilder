json.extract! @result.e_way_bill, :id, :payment_term_id, :procurement_term_id, :doc_number, :date,
              :generated_by, :valid_from, :valid_to, :ref_doc_name, :ref_doc_date, :hsn_code, :reason_for_transportation, :mode, :vehicle_number,
              :location_id, :delivery_location_id
              # :inclusive_of_taxes, #todo add inclusive of tax to table
json.valid_from @result.e_way_bill.valid_from&.strftime("%d-%b-%Y")
json.valid_to @result.e_way_bill.valid_to&.strftime("%d-%b-%Y")
if @result.e_way_bill.vendor.present?
  json.vendor do
    json.extract! @result.e_way_bill.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
  end
end

json.tax do
  json.value @result.e_way_bill.amount&.value
  json.id @result.e_way_bill.amount&.id
  json.currency_id @result.e_way_bill.amount&.currency&.id
end

json.items do
  json.array! @result.e_way_bill.items do |item|
    json.extract! item, :id, :product_id, :description, :hsn_sac, :quantity,
                  :rate, :tax, :tds, :discount, :comment
    json.tax_amount do
      json.value item.tax_amount&.value
      json.id item.tax_amount&.id
      json.currency_id item.tax_amount&.currency&.id
    end
    json.discount_amount do
      json.value item.discount_amount&.value
      json.id item.discount_amount&.id
      json.currency_id item.discount_amount&.currency&.id
    end
    json.total_amount do
      json.value item.total_amount&.value
      json.id item.total_amount&.id
      json.currency_id item.total_amount&.currency&.id
    end
  end
end
json.attachments do
  json.array! @result.e_way_bill.attachments.reject{ |attachment| attachment.file_file_size.nil? } do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.file_file_name
    json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
    json.url attachment.file.url
  end
end

json.comments do
  json.array! @result.e_way_bill.comments do |comment|
    json.extract! comment, :id, :body
    json.created_at comment.created_at.strftime("%b %d, %Y")
    json.created_at_time comment.created_at.strftime("%I:%M%p")
    json.user do
      json.name comment.user&.name

      json.id comment.user&.id
    end
  end
end
