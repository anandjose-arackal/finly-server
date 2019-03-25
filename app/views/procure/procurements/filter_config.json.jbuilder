json.merge! @result.config

json.po_statuses do
  json.array! @result.po_statuses do |status|
    json.extract! status, :id, :name
    json.display_name status.name.humanize
  end
end

json.invoice_statuses do
  json.array! @result.invoice_statuses do |status|
    json.extract! status, :id, :name
    json.display_name status.name.humanize
  end
end

json.locations do 
  json.array! @result.locations do |location|
    json.extract! location, :id, :name
  end
end

json.departments do
  json.array! @result.departments do |department|
    json.extract! department, :id, :name, :cost_center_id
  end
end

json.sub_departments do
  json.array! @result.sub_departments do |dept|
    json.extract! dept, :id, :name, :cost_center_id
    json.parent_id dept.ancestry&.to_i
  end
end


json.cost_centers do
  json.array! @result.cost_centers do |cost_center|
  json.extract! cost_center, :id, :name
  end
end
