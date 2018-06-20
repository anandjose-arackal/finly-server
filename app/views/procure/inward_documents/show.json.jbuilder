json.extract! document, :id, :doc_number, :delivery_date

if @result.inward_document.vendor.present?
  json.vendor do
    json.extract! document.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
  end
end


json.items do
  json.array! @result.inward_document.items do |item|
    json.extract! item, :id, :inventory_line_item_id, :product_id, :description, :quantity, :delivered, :accepted, :rejected
  end
end

json.attachments do
  json.array! @result.inward_document.attachments do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.file_file_name
    json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
    json.url attachment.file.url
  end
end
