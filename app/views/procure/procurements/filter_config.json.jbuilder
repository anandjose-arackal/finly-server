json.merge! @result.config

json.po_statuses do
  json.array! @result.po_statuses do |status|
    json.extract! status, :id, :name
  end
end

json.invoice_statuses do
  json.array! @result.invoice_statuses do |status|
    json.extract! status, :id, :name
  end
end
