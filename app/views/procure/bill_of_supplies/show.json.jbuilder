json.extract! @result.bill_of_supply, :id, :bill_date, :transaction_date, :due_date,
              :roundoff_total_enabled, :roundoff_amount, :location_id, :delivery_location_id,
              # :inclusive_of_taxes, #todo add inclusive of tax to table
              :payment_term_id
json.vendor do
  json.extract! @result.bill_of_supply.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
end

json.tax do
  json.value @result.bill_of_supply.tax_amount&.value
  json.id @result.bill_of_supply.tax_amount&.id
  json.currency_id @result.bill_of_supply.tax_amount&.currency&.id
end

json.discount do
  json.value @result.bill_of_supply.discount_amount&.value
  json.id @result.bill_of_supply.discount_amount&.id
  json.currency_id @result.bill_of_supply.discount_amount&.currency&.id
end
json.balance_due do
  json.value @result.bill_of_supply.balance_amount&.value
  json.id @result.bill_of_supply.balance_amount&.id
  json.currency_id @result.bill_of_supply.balance_amount&.currency&.id
end

json.items do
  json.array! @result.bill_of_supply.items do |item|
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
  json.array! @result.bill_of_supply.attachments.reject{ |attachment| attachment.file_file_size.nil? } do |attachment|
    json.extract! attachment, :id, :description
    json.file_name attachment.file_file_name
    json.file_size (attachment.file_file_size / 1024).round(2).to_s + " KB"
    json.url attachment.file.url
  end
end

json.comments do
  json.array! @result.bill_of_supply.comments do |comment|
    json.extract! comment, :id, :body
    json.created_at comment.created_at.strftime("%b %d, %Y")
    json.created_at_time comment.created_at.strftime("%I:%M%p")
    json.user do
      json.name comment.user&.name

      json.id comment.user&.id
    end
  end
end
