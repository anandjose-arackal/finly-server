json.result do
json.array! @result.paginated_po_templates do |po_template|
  json.extract! po_template, :id, :name
  json.template_name po_template.name
  po = po_template.resource
  json.extract! po, :department, :sub_department, :cost_center
  json.vendor do
    json.id po.vendor&.id
    json.name po.vendor&.name
    json.business_name po.vendor&.business_name
  end
  json.created_on DateUtils.date_formatted(po.created_at)
end

end

json.count @result.count