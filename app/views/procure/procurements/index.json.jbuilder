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

  json.status_tags do
    json.array! p.status_tags do |status_tag|
      json.extract! status_tag, :id, :name, :display_name, :description, :font_icon, :font_icon_color, :icon_path
      json.created_at status_tag.created_at.strftime("%b %d, %y")
      json.created_at_time status_tag.created_at.strftime("%i:%m%p")
    end
  end

end