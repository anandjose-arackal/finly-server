json.array! @result.procurements do |p|
  json.extract! p, :id, :name
  if p.vendor.present?
    json.vendor do
      json.extract! p.vendor, :id, :name, :email, :mobile_number, :authorized, :description, :pan, :gst, :state
    end
  end

  json.user do
    json.extract! p.user, :id, :name, :email, :mobile_number
  end

  json.created_at p.created_at.strftime("%d %m %Y")

  if p.purchase_order.present?
    json.document 'Purchase Order'
  end

end